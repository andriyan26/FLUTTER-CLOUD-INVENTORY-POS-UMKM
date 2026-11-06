-- ============================================================================
-- SEED DATA AWAL UMKM (KATEGORI & MINIMAL 10 PRODUK UMKM)
-- ============================================================================

INSERT INTO public.categories (id, name) VALUES
  ('11111111-1111-1111-1111-111111111101', 'Minuman Kopi & Teh'),
  ('11111111-1111-1111-1111-111111111102', 'Makanan Ringan & Camilan'),
  ('11111111-1111-1111-1111-111111111103', 'Roti & Bakery'),
  ('11111111-1111-1111-1111-111111111104', 'Sembako & Harian'),
  ('11111111-1111-1111-1111-111111111105', 'Kebutuhan Rumah Tangga')
ON CONFLICT (name) DO NOTHING;

INSERT INTO public.products (sku, name, category_id, price, stock, description, images) VALUES
  (
    'UMKM-001',
    'Kopi Susu',
    '11111111-1111-1111-1111-111111111101',
    18000,
    45,
    'Kopi susu gula aren khas UMKM dengan racikan espresso robusta pilihan dan susu segar creamy.',
    ARRAY[
      'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=600&q=80'
    ]
  ),
  (
    'UMKM-002',
    'Keripik Pisang',
    '11111111-1111-1111-1111-111111111102',
    15000,
    38,
    'Keripik pisang kepok renyah dengan balutan bumbu manis gurih khas produksi UMKM lokal.',
    ARRAY[
      'https://images.unsplash.com/photo-1621447504864-d8686e12698c?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?auto=format&fit=crop&w=600&q=80'
    ]
  ),
  (
    'UMKM-003',
    'Roti Cokelat',
    '11111111-1111-1111-1111-111111111103',
    12000,
    25,
    'Roti lembut panggang setiap pagi dengan isian cokelat lumer premium yang kaya rasa.',
    ARRAY[
      'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=600&q=80'
    ]
  ),
  (
    'UMKM-004',
    'Air Mineral',
    '11111111-1111-1111-1111-111111111101',
    5000,
    120,
    'Air mineral pegunungan segar kemasan botol 600ml dingin maupun suhu ruang.',
    ARRAY[
      'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?auto=format&fit=crop&w=600&q=80'
    ]
  ),
  (
    'UMKM-005',
    'Teh Botol',
    '11111111-1111-1111-1111-111111111101',
    7000,
    64,
    'Minuman teh melati asli dalam kemasan siap minum yang menyegarkan.',
    ARRAY[
      'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80'
    ]
  ),
  (
    'UMKM-006',
    'Makaroni Pedas',
    '11111111-1111-1111-1111-111111111102',
    10000,
    7,
    'Makaroni goreng ekstra renyah dengan taburan bumbu cabai daun jeruk level pedas gurih.',
    ARRAY[
      'https://images.unsplash.com/photo-1563379926898-05f4575a45d8?auto=format&fit=crop&w=600&q=80'
    ]
  ),
  (
    'UMKM-007',
    'Sabun',
    '11111111-1111-1111-1111-111111111105',
    6500,
    50,
    'Sabun mandi cair dan batang antibakteri lembut untuk kebutuhan harian keluarga.',
    ARRAY[
      'https://images.unsplash.com/photo-1600857062241-98e5dba7f214?auto=format&fit=crop&w=600&q=80'
    ]
  ),
  (
    'UMKM-008',
    'Mi Instan',
    '11111111-1111-1111-1111-111111111104',
    4000,
    95,
    'Mi instan goreng favorit dengan bumbu lengkap siap saji dalam 3 menit.',
    ARRAY[
      'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?auto=format&fit=crop&w=600&q=80'
    ]
  ),
  (
    'UMKM-009',
    'Beras',
    '11111111-1111-1111-1111-111111111104',
    72000,
    6,
    'Beras putih pulen kualitas super tanpa pemutih kemasan karung praktis 5 Kg.',
    ARRAY[
      'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=600&q=80'
    ]
  ),
  (
    'UMKM-010',
    'Gula Pasir',
    '11111111-1111-1111-1111-111111111104',
    17500,
    8,
    'Gula pasir kristal putih murni 1 Kg dari tebu pilihan untuk minuman dan masakan.',
    ARRAY[
      'https://images.unsplash.com/photo-1581441363689-1f3c3c414635?auto=format&fit=crop&w=600&q=80'
    ]
  )
ON CONFLICT (sku) DO NOTHING;

