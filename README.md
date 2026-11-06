# Cloud Inventory & POS UMKM (Flutter Web + Supabase + GitHub Codespaces)

Aplikasi **Cloud Inventory & POS (Point of Sales)** modern, responsif, dan ringan (anti-lag) untuk UMKM Indonesia, dibangun menggunakan **Flutter (Material Design 3)**, **Supabase (PostgreSQL, Auth, Storage, RLS)**, serta terintegrasi penuh dengan **GitHub Codespaces** dan **GitHub Actions CI/CD**.

Desain dan interaksi aplikasi ini dirancang mengikuti **3 Video Referensi Utama** dengan frame simulator bawaan **iPhone 13 (390 × 844 px)** serta dukungan penuh layout **Tablet** dan **Desktop Split POS**:
1. **`KONSEP LOGIN.mp4`**: Animated Splash Screen + Header Hijau Tua dengan maskot kurir/toko, form kapsul (`borderRadius: 30`), validasi input real-time (*"That email doesn't look right"* & *"Use at least 6 characters"*), show/hide password, tombol kapsul hijau **Log In**, dan pilihan akun cepat.
2. **`KONSEP SETELAH LOGIN.mp4`**: Dashboard & Katalog modern dengan sapaan pengguna (*"Bonjour, ..."*), headline dua warna, search bar kapsul dengan tombol oranye, filter kategori bulat horizontal, grid kartu produk 2 kolom dengan tombol `+` oranye yang membuka *Interactive Quantity Sheet* (`01` counter besar + animasi checkmark `✓`), serta **Floating Orange Pill Bottom Navigation Bar**.
3. **`KONSEP LIHAT DETAIL BARANG.mp4`**: Halaman Detail Produk interaktif dengan **Horizontal Swipe (`PageView`)**, transisi *Radial Gradient* dinamis sesuai produk (Espresso Brown, Caramel Mocha, Slate Blue, Emerald), lingkaran halo bercahaya di belakang foto produk, pilihan ukuran/varian (`Small`, `Medium`, `Large`) yang mengubah harga secara real-time, kartu *frosted glass* (`Price` & `Score • Stok`), serta tombol **Confirm Selection • Tambah Kasir**.

---

## 1. Teknologi yang Digunakan

- **Frontend**: Flutter SDK (Stable), Dart 3, Material Design 3, Responsive Layout (`LayoutBuilder` + **iPhone 13 Frame Simulator Wrapper**).
- **State Management**: `provider` (konsisten, modular, dan ringan tanpa membebani RAM/CPU).
- **Backend & Database**: Supabase (`supabase_flutter`), PostgreSQL, Row Level Security (RLS), Atomic Stored Procedure (`process_pos_checkout`), dan Supabase Storage (`product-images`).
- **Cloud Development & CI/CD**:
  - **GitHub Codespaces** (`.devcontainer/devcontainer.json`) menggunakan image `ghcr.io/cirruslabs/flutter:stable` sehingga tidak menginstal ulang Flutter SDK setiap kali dibuka.
  - **GitHub Actions** (`.github/workflows/flutter-ci.yml` & `flutter-web-deploy.yml`) untuk *Flutter Analyze*, *Flutter Test*, *Cloud Web Build*, dan deployment otomatis ke **GitHub Pages**.

---

## 2. Struktur Folder Source Code

```text
├── .devcontainer/
│   └── devcontainer.json              # Konfigurasi GitHub Codespaces siap pakai
├── .github/
│   └── workflows/
│       ├── flutter-ci.yml             # CI: Analyze, Test, Build Web Release
│       └── flutter-web-deploy.yml     # CD: Auto-deploy ke GitHub Pages
├── supabase/
│   ├── schema.sql                     # Tabel PostgreSQL, Index, RLS, & Fungsi Checkout Atomik
│   └── seed.sql                       # Seed 5 Kategori & 10 Produk UMKM
├── web/
│   ├── index.html                     # Entry HTML Flutter Web + Preloader
│   └── manifest.json
├── lib/
│   ├── main.dart                      # Entry point aplikasi & MultiProvider
│   ├── core/
│   │   ├── config/supabase_config.dart
│   │   ├── constants/app_constants.dart
│   │   ├── theme/app_colors.dart & app_theme.dart
│   │   ├── utils/currency_formatter.dart & validators.dart
│   │   └── widgets/iphone13_frame_wrapper.dart & custom_cached_image.dart
│   ├── models/                        # Data models (User, Category, Product, Cart, Transaction)
│   ├── services/                      # Auth, Product, Category, Transaction, Report, Storage
│   ├── providers/                     # State management (Provider)
│   ├── screens/
│   │   ├── auth/                      # SplashScreen & LoginScreen (Konsep Video 1)
│   │   ├── dashboard/                 # DashboardScreen (Konsep Video 2)
│   │   ├── products/                  # Catalog, Swipe Detail (Video 3), & Form CRUD
│   │   ├── categories/                # CategoryManagementScreen
│   │   ├── pos/                       # PosScreen, QuickAddSheet (Video 2), ReceiptDialog
│   │   ├── transactions/              # TransactionHistoryScreen
│   │   ├── reports/                   # SalesReportScreen (Filter + Export CSV)
│   │   └── settings/                  # SettingsScreen & Viewport Switcher
│   ├── widgets/                       # ProductCard, StatCard, FloatingOrangeNavbar
│   └── routes/
│       └── app_router.dart
└── test/
    └── widget_test.dart               # Pengujian unit & widget otomatis
```

---

## 3. Cara Membuka di GitHub Codespaces (Tanpa Lag di Laptop)

1. Push kode ini ke repository GitHub Anda:
   `https://github.com/andriyan26/FLUTTER-CLOUD-INVENTORY-POS-UMKM`
2. Buka halaman repository di browser, klik tombol hijau **`<> Code`** lalu pilih tab **`Codespaces`** -> **`Create codespace on main`**.
3. Codespaces akan langsung memuat image Flutter yang sudah terinstal (`ghcr.io/cirruslabs/flutter:stable`) dan menjalankan `flutter pub get` secara otomatis.

---

## 4. Cara Menjalankan Flutter Web di Codespaces

Di terminal VS Code Codespaces, jalankan perintah berikut:

```bash
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080
```

Port `8080` akan otomatis di-*forward* dan membuka **Preview Browser** dengan tampilan **iPhone 13 (390×844)** yang dapat diubah ke **Tablet** atau **Desktop Split View** melalui toolbar atas.

---

## 5. Setup Database Supabase & Storage

1. Buat project baru di [Supabase Dashboard](https://supabase.com/dashboard).
2. Buka menu **SQL Editor**, salin seluruh isi file [`supabase/schema.sql`](supabase/schema.sql), lalu klik **Run**.
3. Masih di **SQL Editor**, salin seluruh isi file [`supabase/seed.sql`](supabase/seed.sql), lalu klik **Run** untuk mengisi 10 produk UMKM awal (*Kopi Susu, Keripik Pisang, Roti Cokelat, Air Mineral, Teh Botol, Makaroni Pedas, Sabun, Mi Instan, Beras, Gula Pasir*).
4. Bucket storage publik bernama `product-images` beserta kebijakan RLS-nya otomatis dibuat oleh `schema.sql`.

---

## 6. Konfigurasi Environment Variables (Tanpa Commit Secret)

Jangan pernah menulis `service_role` key di kode Flutter. Gunakan `SUPABASE_URL` dan `SUPABASE_ANON_KEY` melalui `--dart-define` atau **GitHub Actions Secrets**:

- Di **GitHub Repository Settings** -> **Secrets and variables** -> **Actions**, tambahkan:
  - `SUPABASE_URL`: URL project Supabase Anda (`https://xxxx.supabase.co`)
  - `SUPABASE_ANON_KEY`: `anon` public key Supabase Anda

Saat menjalankan di Codespaces dengan Supabase aktif:
```bash
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080 \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGci...
```

---

## 7. Informasi Akun Demo (Smart Cloud Demo Mode)

Apabila `SUPABASE_URL` belum diisi, aplikasi otomatis berjalan dalam **Smart Cloud Demo Mode** yang terpisah dan siap diuji penuh:

| Role | Email / Username | Password | Hak Akses |
| :--- | :--- | :--- | :--- |
| **Admin UMKM** | `dailyflutterui@gmail.com` *(atau klik tombol **Admin**)* | `123456` | CRUD Produk, CRUD Kategori, Stok, POS, Riwayat, Laporan |
| **Kasir UMKM** | `kasir@umkm.id` *(atau klik tombol **Kasir**)* | `123456` | Melihat Katalog, Transaksi POS, Cetak Struk, Lihat Riwayat |

---

## 8. Cara Build & Deploy (Cloud Build via GitHub Actions)

- Setiap kali Anda melakukan `git push origin main`, workflow [`.github/workflows/flutter-ci.yml`](.github/workflows/flutter-ci.yml) dan [`.github/workflows/flutter-web-deploy.yml`](.github/workflows/flutter-web-deploy.yml) akan berjalan di server cloud GitHub.
- Untuk mengaktifkan hosting gratis di **GitHub Pages**:
  1. Buka repository GitHub Anda -> **Settings** -> **Pages**.
  2. Pada bagian **Build and deployment** > **Source**, pilih **GitHub Actions**.
  3. Aplikasi Flutter Web Anda akan otomatis ter-deploy dan dapat diakses melalui link GitHub Pages dari laptop maupun smartphone.

---

## 9. Troubleshooting

- **Laptop terasa berat saat membuka banyak tab?**
  Tutup tab yang tidak digunakan. Ingat bahwa GitHub Codespaces memindahkan kompilasi Flutter ke cloud, namun browser tetap menggunakan RAM lokal saat merender halaman web.
- **Kategori gagal dihapus?**
  Sesuai aturan integritas data, kategori yang masih memiliki produk aktif tidak dapat dihapus sebelum produk di dalamnya dipindahkan atau dihapus.
- **Checkout gagal karena stok kurang?**
  Sistem memvalidasi stok baik di sisi Flutter maupun secara atomik di database (`FOR UPDATE` row lock pada PostgreSQL) untuk mencegah stok negatif.
