-- ============================================================================
-- CLOUD INVENTORY & POS UMKM — SUPABASE POSTGRESQL SCHEMA & RLS
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. TABEL PROFILES (Role: 'admin' atau 'kasir')
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'kasir' CHECK (role IN ('admin', 'kasir')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. TABEL CATEGORIES
CREATE TABLE IF NOT EXISTS public.categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. TABEL PRODUCTS (Harga disimpan sebagai INTEGER Rupiah)
CREATE TABLE IF NOT EXISTS public.products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sku TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
  price INTEGER NOT NULL CHECK (price >= 0),
  stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
  description TEXT NOT NULL DEFAULT '',
  images TEXT[] NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. TABEL TRANSACTIONS
CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  transaction_code TEXT NOT NULL UNIQUE,
  customer_name TEXT DEFAULT 'Pelanggan Umum',
  subtotal INTEGER NOT NULL CHECK (subtotal >= 0),
  total INTEGER NOT NULL CHECK (total >= 0),
  payment_method TEXT NOT NULL CHECK (payment_method IN ('Cash', 'Transfer', 'QRIS')),
  amount_paid INTEGER NOT NULL CHECK (amount_paid >= total),
  change_amount INTEGER NOT NULL DEFAULT 0 CHECK (change_amount >= 0),
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. TABEL TRANSACTION_DETAILS
CREATE TABLE IF NOT EXISTS public.transaction_details (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  transaction_id UUID NOT NULL REFERENCES public.transactions(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
  product_name TEXT NOT NULL,
  price INTEGER NOT NULL CHECK (price >= 0),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  subtotal INTEGER NOT NULL CHECK (subtotal >= 0)
);

-- ============================================================================
-- INDEXES UNTUK PERFORMA QUERY TINGGI (ANTI-LAG)
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_products_category_id ON public.products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_sku ON public.products(sku);
CREATE INDEX IF NOT EXISTS idx_products_name ON public.products(name);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON public.transactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_code ON public.transactions(transaction_code);
CREATE INDEX IF NOT EXISTS idx_transaction_details_tx_id ON public.transaction_details(transaction_id);

-- Trigger otomatis update updated_at pada products
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_products_updated_at ON public.products;
CREATE TRIGGER trg_products_updated_at
BEFORE UPDATE ON public.products
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Trigger otomatis membuat profile saat user baru mendaftar di Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'kasir')
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- FUNGSI HELPER CEK ROLE ADMIN
-- ============================================================================
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) — PROTEKSI ROLE DI LEVEL DATABASE
-- ============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_details ENABLE ROW LEVEL SECURITY;

-- Policies: profiles
CREATE POLICY "Authenticated users can view profiles"
  ON public.profiles FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id);

-- Policies: categories (Semua user login bisa baca, hanya Admin bisa CRUD)
CREATE POLICY "Anyone authenticated can read categories"
  ON public.categories FOR SELECT TO authenticated USING (true);

CREATE POLICY "Only admin can insert categories"
  ON public.categories FOR INSERT TO authenticated WITH CHECK (public.is_admin());

CREATE POLICY "Only admin can update categories"
  ON public.categories FOR UPDATE TO authenticated USING (public.is_admin());

CREATE POLICY "Only admin can delete categories"
  ON public.categories FOR DELETE TO authenticated USING (public.is_admin());

-- Policies: products (Semua user login bisa baca, hanya Admin bisa tambah/edit/hapus)
CREATE POLICY "Anyone authenticated can read products"
  ON public.products FOR SELECT TO authenticated USING (true);

CREATE POLICY "Only admin can insert products"
  ON public.products FOR INSERT TO authenticated WITH CHECK (public.is_admin());

CREATE POLICY "Only admin can update products"
  ON public.products FOR UPDATE TO authenticated USING (public.is_admin());

CREATE POLICY "Only admin can delete products"
  ON public.products FOR DELETE TO authenticated USING (public.is_admin());

-- Policies: transactions & transaction_details (Admin & Kasir bisa buat & lihat transaksi)
CREATE POLICY "Authenticated users can view transactions"
  ON public.transactions FOR SELECT TO authenticated
  USING (public.is_admin() OR user_id = auth.uid() OR user_id IS NULL);

CREATE POLICY "Authenticated users can create transactions"
  ON public.transactions FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Authenticated users can view transaction details"
  ON public.transaction_details FOR SELECT TO authenticated USING (true);

CREATE POLICY "Authenticated users can create transaction details"
  ON public.transaction_details FOR INSERT TO authenticated WITH CHECK (true);

-- ============================================================================
-- ATOMIC DATABASE TRANSACTION UNTUK CHECKOUT KASIR (ANTI RACE-CONDITION STOK)
-- ============================================================================
CREATE OR REPLACE FUNCTION public.process_pos_checkout(
  p_transaction_code TEXT,
  p_customer_name TEXT,
  p_payment_method TEXT,
  p_amount_paid INTEGER,
  p_items JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_item JSONB;
  v_product RECORD;
  v_subtotal INTEGER := 0;
  v_total INTEGER := 0;
  v_change INTEGER := 0;
  v_tx_id UUID;
  v_qty INTEGER;
BEGIN
  IF jsonb_array_length(p_items) = 0 THEN
    RAISE EXCEPTION 'Keranjang belanja tidak boleh kosong.';
  END IF;

  -- Validasi stok dengan row-level lock (FOR UPDATE)
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    v_qty := (v_item->>'quantity')::INTEGER;
    IF v_qty <= 0 THEN
      RAISE EXCEPTION 'Jumlah barang harus lebih dari 0.';
    END IF;

    SELECT id, name, price, stock INTO v_product
    FROM public.products
    WHERE id = (v_item->>'product_id')::UUID
    FOR UPDATE;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'Produk tidak ditemukan di database.';
    END IF;

    IF v_product.stock < v_qty THEN
      RAISE EXCEPTION 'Stok % tidak mencukupi (Tersisa: %, Diminta: %).',
        v_product.name, v_product.stock, v_qty;
    END IF;

    v_subtotal := v_subtotal + (v_product.price * v_qty);
  END LOOP;

  v_total := v_subtotal;

  IF p_amount_paid < v_total THEN
    RAISE EXCEPTION 'Nominal pembayaran (Rp %) kurang dari total belanja (Rp %).',
      p_amount_paid, v_total;
  END IF;

  v_change := p_amount_paid - v_total;

  -- Simpan Header Transaksi
  INSERT INTO public.transactions (
    transaction_code, customer_name, subtotal, total,
    payment_method, amount_paid, change_amount, user_id
  ) VALUES (
    p_transaction_code,
    COALESCE(NULLIF(TRIM(p_customer_name), ''), 'Pelanggan Umum'),
    v_subtotal,
    v_total,
    p_payment_method,
    p_amount_paid,
    v_change,
    auth.uid()
  ) RETURNING id INTO v_tx_id;

  -- Simpan Detail & Kurangi Stok Secara Atomik
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    v_qty := (v_item->>'quantity')::INTEGER;
    SELECT id, name, price INTO v_product
    FROM public.products
    WHERE id = (v_item->>'product_id')::UUID;

    INSERT INTO public.transaction_details (
      transaction_id, product_id, product_name, price, quantity, subtotal
    ) VALUES (
      v_tx_id,
      v_product.id,
      v_product.name,
      v_product.price,
      v_qty,
      v_product.price * v_qty
    );

    UPDATE public.products
    SET stock = stock - v_qty
    WHERE id = v_product.id;
  END LOOP;

  RETURN jsonb_build_object(
    'transaction_id', v_tx_id,
    'transaction_code', p_transaction_code,
    'subtotal', v_subtotal,
    'total', v_total,
    'change_amount', v_change
  );
END;
$$;

-- ============================================================================
-- SUPABASE STORAGE BUCKET UNTUK FOTO PRODUK
-- ============================================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Public read access for product images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'product-images');

CREATE POLICY "Authenticated admin upload product images"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'product-images');
