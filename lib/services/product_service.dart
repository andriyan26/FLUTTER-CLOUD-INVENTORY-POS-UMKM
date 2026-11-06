import '../core/config/supabase_config.dart';
import '../models/product_model.dart';
import 'local_db_service.dart';

class ProductService {
  final LocalDbService _localDb = LocalDbService();
  static final List<ProductModel> _demoProducts = [
    // =========================================================================
    // KATEGORI 1: MINUMAN (10 Produk dari folder Produk/Minuman)
    // =========================================================================
    ProductModel(
      id: 'prod-1',
      sku: 'MIN-001',
      name: 'Kopi Susu Gula Aren',
      categoryId: 'cat-1',
      categoryName: 'Minuman',
      price: 18000,
      stock: 45,
      description:
          'Es kopi susu gula aren khas UMKM dengan espresso robusta pilihan dan susu segar creamy.',
      images: const ['assets/produk/minuman_kopi_susu_gula_aren.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-2',
      sku: 'MIN-002',
      name: 'Cappuccino Creamy',
      categoryId: 'cat-1',
      categoryName: 'Minuman',
      price: 22000,
      stock: 38,
      description:
          'Paduan espresso hangat dengan microfoam susu lembut dan taburan cokelat aromatik.',
      images: const ['assets/produk/minuman_cappuccino_creamy.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-3',
      sku: 'MIN-003',
      name: 'Es Cokelat Signature',
      categoryId: 'cat-1',
      categoryName: 'Minuman',
      price: 20000,
      stock: 34,
      description:
          'Minuman es cokelat Belgia kental dan lembut dengan rasa manis pahit yang seimbang.',
      images: const ['assets/produk/minuman_es_cokelat_signature.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-4',
      sku: 'MIN-004',
      name: 'Matcha Latte',
      categoryId: 'cat-1',
      categoryName: 'Minuman',
      price: 23000,
      stock: 30,
      description:
          'Iced matcha latte premium dari pucuk teh hijau Jepang pilihan berpadu susu segar.',
      images: const ['assets/produk/minuman_matcha_latte.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-5',
      sku: 'MIN-005',
      name: 'Thai Tea',
      categoryId: 'cat-1',
      categoryName: 'Minuman',
      price: 15000,
      stock: 52,
      description:
          'Racikan teh Thailand autentik dengan susu kental manis gurih dan aroma rempah khas.',
      images: const ['assets/produk/minuman_thai_tea.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-6',
      sku: 'MIN-006',
      name: 'Lemon Tea',
      categoryId: 'cat-1',
      categoryName: 'Minuman',
      price: 12000,
      stock: 60,
      description:
          'Es teh segar dengan perasan lemon asli dan daun mint dingin pelepas dahaga.',
      images: const ['assets/produk/minuman_lemon_tea.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-7',
      sku: 'MIN-007',
      name: 'Es Teh Manis',
      categoryId: 'cat-1',
      categoryName: 'Minuman',
      price: 7000,
      stock: 85,
      description:
          'Seduhan teh melati pilihan dengan gula murni disajikan dingin bersama es batu kristal.',
      images: const ['assets/produk/minuman_es_teh_manis.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-8',
      sku: 'MIN-008',
      name: 'Jus Alpukat',
      categoryId: 'cat-1',
      categoryName: 'Minuman',
      price: 18000,
      stock: 28,
      description:
          'Jus buah alpukat mentega segar bertekstur lembut dengan siraman cokelat kental.',
      images: const ['assets/produk/minuman_jus_alpukat.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-9',
      sku: 'MIN-009',
      name: 'Jus Mangga',
      categoryId: 'cat-1',
      categoryName: 'Minuman',
      price: 17000,
      stock: 32,
      description:
          'Smoothie mangga harum manis segar kaya vitamin dengan potongan buah asli.',
      images: const ['assets/produk/minuman_jus_mangga.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-10',
      sku: 'MIN-010',
      name: 'Mineral Water',
      categoryId: 'cat-1',
      categoryName: 'Minuman',
      price: 5000,
      stock: 120,
      description:
          'Air mineral pegunungan murni kemasan botol 600ml segar dan higienis.',
      images: const ['assets/produk/minuman_mineral_water.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
      updatedAt: DateTime.now(),
    ),

    // =========================================================================
    // KATEGORI 2: MAKANAN (10 Produk dari folder Produk/Makanan)
    // =========================================================================
    ProductModel(
      id: 'prod-11',
      sku: 'MKN-001',
      name: 'Nasi Goreng Spesial',
      categoryId: 'cat-2',
      categoryName: 'Makanan',
      price: 25000,
      stock: 40,
      description:
          'Nasi goreng bumbu rempah nusantara dengan telur mata sapi, suwiran ayam, dan kerupuk.',
      images: const ['assets/produk/makanan_nasi_goreng_spesial.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 55)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-12',
      sku: 'MKN-002',
      name: 'Ayam Goreng Crispy',
      categoryId: 'cat-2',
      categoryName: 'Makanan',
      price: 22000,
      stock: 36,
      description:
          'Ayam goreng tepung ekstra renyah di luar dan juicy di dalam dengan sambal spesial.',
      images: const ['assets/produk/makanan_ayam_goreng_crispy.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 60)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-13',
      sku: 'MKN-003',
      name: 'Burger Spesial',
      categoryId: 'cat-2',
      categoryName: 'Makanan',
      price: 28000,
      stock: 25,
      description:
          'Gourmet beef burger dengan patty daging sapi panggang, keju lumer, dan saus spesial.',
      images: const ['assets/produk/makanan_burger_spesial.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 65)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-14',
      sku: 'MKN-004',
      name: 'Sate Ayam Madura',
      categoryId: 'cat-2',
      categoryName: 'Makanan',
      price: 24000,
      stock: 30,
      description:
          'Sate ayam panggang arang sebanyak 10 tusuk dengan bumbu kacang kental dan kecap manis.',
      images: const ['assets/produk/makanan_sate_ayam_madura.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 70)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-15',
      sku: 'MKN-005',
      name: 'Bakso Sapi',
      categoryId: 'cat-2',
      categoryName: 'Makanan',
      price: 20000,
      stock: 42,
      description:
          'Semangkuk bakso urat dan halus daging sapi asli dengan kuah kaldu gurih hangat.',
      images: const ['assets/produk/makanan_bakso_sapi.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 75)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-16',
      sku: 'MKN-006',
      name: 'Mie Goreng Telur',
      categoryId: 'cat-2',
      categoryName: 'Makanan',
      price: 18000,
      stock: 48,
      description:
          'Mie goreng tek-tek hangat dengan sayuran segar, bumbu bawang, dan telur ceplok.',
      images: const ['assets/produk/makanan_mie_goreng_telur.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 80)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-17',
      sku: 'MKN-007',
      name: 'Nasi Bakar Special',
      categoryId: 'cat-2',
      categoryName: 'Makanan',
      price: 23000,
      stock: 26,
      description:
          'Nasi gurih berbumbu kemangi dan suwiran ayam pedas yang dibakar dalam bungkus daun pisang.',
      images: const ['assets/produk/makanan_nasi_bakar_special.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 85)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-18',
      sku: 'MKN-008',
      name: 'Soto Ayam',
      categoryId: 'cat-2',
      categoryName: 'Makanan',
      price: 19000,
      stock: 35,
      description:
          'Soto ayam kuah kuning bening kaya rempah dengan soun, telur rebus, dan taburan koya.',
      images: const ['assets/produk/makanan_soto_ayam.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 90)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-19',
      sku: 'MKN-009',
      name: 'Chicken Wings',
      categoryId: 'cat-2',
      categoryName: 'Makanan',
      price: 24000,
      stock: 29,
      description:
          'Sayap ayam goreng berbalut saus BBQ pedas manis karamel dengan taburan wijen.',
      images: const ['assets/produk/makanan_chicken_wings.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 95)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-20',
      sku: 'MKN-010',
      name: 'Spaghetti Bolognese',
      categoryId: 'cat-2',
      categoryName: 'Makanan',
      price: 26000,
      stock: 24,
      description:
          'Pasta spaghetti al dente dengan saus tomat daging sapi cincang dan taburan keju parmesan.',
      images: const ['assets/produk/makanan_spaghetti_bolognese.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 100)),
      updatedAt: DateTime.now(),
    ),

    // =========================================================================
    // KATEGORI 3: ROTI (10 Produk dari folder Produk/Roti)
    // =========================================================================
    ProductModel(
      id: 'prod-21',
      sku: 'RTI-001',
      name: 'Butter Croissant',
      categoryId: 'cat-3',
      categoryName: 'Roti',
      price: 16000,
      stock: 28,
      description:
          'Croissant mentega Prancis berlapis renyah keemasan yang dipanggang segar setiap pagi.',
      images: const ['assets/produk/roti_butter_croissant.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 105)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-22',
      sku: 'RTI-002',
      name: 'Cinnamon Roll',
      categoryId: 'cat-3',
      categoryName: 'Roti',
      price: 18000,
      stock: 22,
      description:
          'Roti gulung kayu manis lembut beraroma hangat dengan krim frosting vanila di atasnya.',
      images: const ['assets/produk/roti_cinnamon_roll.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 110)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-23',
      sku: 'RTI-003',
      name: 'Donut Glaze',
      categoryId: 'cat-3',
      categoryName: 'Roti',
      price: 12000,
      stock: 44,
      description:
          'Donat kentang empuk mengembang dengan lapisan glaze gula dan cokelat aneka rasa.',
      images: const ['assets/produk/roti_donut_glaze.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 115)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-24',
      sku: 'RTI-004',
      name: 'Roti Bakar Coklat Keju',
      categoryId: 'cat-3',
      categoryName: 'Roti',
      price: 17000,
      stock: 34,
      description:
          'Roti tawar tebal panggang mentega dengan isian meses cokelat lumer dan parutan keju melimpah.',
      images: const ['assets/produk/roti_roti_bakar_coklat_keju.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 120)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-25',
      sku: 'RTI-005',
      name: 'Waffle Cokelat',
      categoryId: 'cat-3',
      categoryName: 'Roti',
      price: 20000,
      stock: 26,
      description:
          'Belgian waffle renyah hangat dengan siraman saus cokelat premium dan gula halus.',
      images: const ['assets/produk/roti_waffle_cokelat.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 125)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-26',
      sku: 'RTI-006',
      name: 'Pancake Madu',
      categoryId: 'cat-3',
      categoryName: 'Roti',
      price: 19000,
      stock: 24,
      description:
          'Tumpukan pancake lembut dengan lelehan mentega gurih dan sirup madu alami.',
      images: const ['assets/produk/roti_pancake_madu.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 130)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-27',
      sku: 'RTI-007',
      name: 'Churros Cokelat',
      categoryId: 'cat-3',
      categoryName: 'Roti',
      price: 16000,
      stock: 32,
      description:
          'Churros goreng renyah bertabur gula kayu manis lengkap dengan saus cocolan cokelat hangat.',
      images: const ['assets/produk/roti_churros_cokelat.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 135)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-28',
      sku: 'RTI-008',
      name: 'Garlic Bread',
      categoryId: 'cat-3',
      categoryName: 'Roti',
      price: 15000,
      stock: 30,
      description:
          'Roti baguette panggang renyah dengan olesan mentega bawang putih dan daun parsley.',
      images: const ['assets/produk/roti_garlic_bread.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 140)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-29',
      sku: 'RTI-009',
      name: 'Roti Srikaya',
      categoryId: 'cat-3',
      categoryName: 'Roti',
      price: 14000,
      stock: 36,
      description:
          'Roti panggang lembut khas kopitiam dengan selai srikaya pandan harum dan butter dingin.',
      images: const ['assets/produk/roti_roti_srikaya.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 145)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-30',
      sku: 'RTI-010',
      name: 'Sandwich Keju Telur',
      categoryId: 'cat-3',
      categoryName: 'Roti',
      price: 21000,
      stock: 27,
      description:
          'Sandwich sarapan bergizi dengan roti gandum panggang, telur dadar lembut, dan keju cheddar.',
      images: const ['assets/produk/roti_sandwich_keju_telur.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 150)),
      updatedAt: DateTime.now(),
    ),

    // =========================================================================
    // KATEGORI 4: CEMILAN (10 Produk dari folder Produk/Cemilan)
    // =========================================================================
    ProductModel(
      id: 'prod-31',
      sku: 'CML-001',
      name: 'Dimsum Mentai',
      categoryId: 'cat-4',
      categoryName: 'Cemilan',
      price: 22000,
      stock: 30,
      description:
          'Dimsum ayam udang kukus lembut dengan siraman saus mentai bakar gurih creamy.',
      images: const ['assets/produk/cemilan_dimsum_mentai.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 155)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-32',
      sku: 'CML-002',
      name: 'Kentang Goreng',
      categoryId: 'cat-4',
      categoryName: 'Cemilan',
      price: 15000,
      stock: 48,
      description:
          'French fries potong tebal goreng keemasan renyah dengan taburan garam gurih dan saus.',
      images: const ['assets/produk/cemilan_kentang_goreng.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 160)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-33',
      sku: 'CML-003',
      name: 'Cireng Rujak',
      categoryId: 'cat-4',
      categoryName: 'Cemilan',
      price: 13000,
      stock: 42,
      description:
          'Cireng crispy khas Bandung dengan tekstur renyah kenyal dan sambal rujak gula merah pedas.',
      images: const ['assets/produk/cemilan_cireng_rujak.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 165)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-34',
      sku: 'CML-004',
      name: 'Pisang Goreng Keju',
      categoryId: 'cat-4',
      categoryName: 'Cemilan',
      price: 16000,
      stock: 35,
      description:
          'Pisang raja goreng tepung krispi dengan parutan keju melimpah dan susu kental manis.',
      images: const ['assets/produk/cemilan_pisang_goreng_keju.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 170)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-35',
      sku: 'CML-005',
      name: 'Tahu Crispy',
      categoryId: 'cat-4',
      categoryName: 'Cemilan',
      price: 12000,
      stock: 50,
      description:
          'Potongan tahu dadu goreng tepung berbumbu bawang gurih dengan cabai rawit segar.',
      images: const ['assets/produk/cemilan_tahu_crispy.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 175)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-36',
      sku: 'CML-006',
      name: 'Sosis Bakar',
      categoryId: 'cat-4',
      categoryName: 'Cemilan',
      price: 15000,
      stock: 38,
      description:
          'Sosis sapi jumbo panggang olesan saus barbekyu manis pedas dengan mayones.',
      images: const ['assets/produk/cemilan_sosis_bakar.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 180)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-37',
      sku: 'CML-007',
      name: 'Onion Rings',
      categoryId: 'cat-4',
      categoryName: 'Cemilan',
      price: 15000,
      stock: 33,
      description:
          'Cincin bawang bombay berbalut tepung roti renyah keemasan dengan saus tartar.',
      images: const ['assets/produk/cemilan_onion_rings.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 185)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-38',
      sku: 'CML-008',
      name: 'Singkong Keju',
      categoryId: 'cat-4',
      categoryName: 'Cemilan',
      price: 14000,
      stock: 37,
      description:
          'Singkong goreng merekah empuk di dalam dan renyah di luar dengan taburan keju gurih.',
      images: const ['assets/produk/cemilan_singkong_keju.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 190)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-39',
      sku: 'CML-009',
      name: 'Keripik Singkong Balado',
      categoryId: 'cat-4',
      categoryName: 'Cemilan',
      price: 12000,
      stock: 55,
      description:
          'Keripik singkong iris tipis renyah berbalut bumbu balado cabai merah manis pedas.',
      images: const ['assets/produk/cemilan_keripik_singkong_balado.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 195)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-40',
      sku: 'CML-010',
      name: 'Makaroni Pedas',
      categoryId: 'cat-4',
      categoryName: 'Cemilan',
      price: 10000,
      stock: 7,
      description:
          'Makaroni goreng renyah dengan taburan bumbu cabai daun jeruk ekstra gurih.',
      images: const ['assets/produk/cemilan_makaroni_pedas.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 200)),
      updatedAt: DateTime.now(),
    ),

    // =========================================================================
    // KATEGORI 5: SEMBAKO (10 Produk dari folder Produk/Sembako)
    // =========================================================================
    ProductModel(
      id: 'prod-41',
      sku: 'SMB-001',
      name: 'Beras Premium',
      categoryId: 'cat-5',
      categoryName: 'Sembako',
      price: 72000,
      stock: 6,
      description:
          'Beras putih pandan wangi pulen kualitas super tanpa pemutih kemasan 5 Kg.',
      images: const ['assets/produk/sembako_beras_premium.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 205)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-42',
      sku: 'SMB-002',
      name: 'Minyak Goreng',
      categoryId: 'cat-5',
      categoryName: 'Sembako',
      price: 34000,
      stock: 28,
      description:
          'Minyak goreng kelapa sawit jernih 2 kali penyaringan kemasan pouch 2 Liter.',
      images: const ['assets/produk/sembako_minyak_goreng.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 210)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-43',
      sku: 'SMB-003',
      name: 'Gula Pasir Putih',
      categoryId: 'cat-5',
      categoryName: 'Sembako',
      price: 17500,
      stock: 8,
      description:
          'Gula pasir kristal putih murni 1 Kg dari tebu pilihan untuk minuman dan kue.',
      images: const ['assets/produk/sembako_gula_pasir_putih.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 215)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-44',
      sku: 'SMB-004',
      name: 'Telur Ayam Negeri',
      categoryId: 'cat-5',
      categoryName: 'Sembako',
      price: 29000,
      stock: 24,
      description:
          'Telur ayam negeri segar pilihan kaya protein kemasan tray 1 Kg.',
      images: const ['assets/produk/sembako_telur_ayam_negeri.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 220)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-45',
      sku: 'SMB-005',
      name: 'Mie Instan',
      categoryId: 'cat-5',
      categoryName: 'Sembako',
      price: 4000,
      stock: 95,
      description:
          'Mie instan favorit keluarga dengan bumbu lengkap praktis siap saji.',
      images: const ['assets/produk/sembako_mie_instan.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 225)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-46',
      sku: 'SMB-006',
      name: 'Tepung Terigu',
      categoryId: 'cat-5',
      categoryName: 'Sembako',
      price: 13500,
      stock: 40,
      description:
          'Tepung terigu serbaguna kualitas tinggi kemasan 1 Kg untuk aneka gorengan dan roti.',
      images: const ['assets/produk/sembako_tepung_terigu.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 230)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-47',
      sku: 'SMB-007',
      name: 'Kecap Manis',
      categoryId: 'cat-5',
      categoryName: 'Sembako',
      price: 19500,
      stock: 36,
      description:
          'Kecap manis kedelai hitam pilihan kental dan gurih meresap untuk masakan.',
      images: const ['assets/produk/sembako_kecap_manis.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 235)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-48',
      sku: 'SMB-008',
      name: 'Kental Manis',
      categoryId: 'cat-5',
      categoryName: 'Sembako',
      price: 12500,
      stock: 46,
      description:
          'Krimer kental manis lezat cocok untuk campuran kopi, minuman dingin, dan topping roti.',
      images: const ['assets/produk/sembako_kental_manis.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 240)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-49',
      sku: 'SMB-009',
      name: 'Teh Celup',
      categoryId: 'cat-5',
      categoryName: 'Sembako',
      price: 8500,
      stock: 62,
      description:
          'Teh hitam celup pilihan isi 25 kantong dengan warna pekat dan aroma menenangkan.',
      images: const ['assets/produk/sembako_teh_celup.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 245)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-50',
      sku: 'SMB-010',
      name: 'Garam Dapur',
      categoryId: 'cat-5',
      categoryName: 'Sembako',
      price: 5000,
      stock: 75,
      description:
          'Garam meja beryodium halus dan bersih kemasan 500 gram untuk bumbu masakan.',
      images: const ['assets/produk/sembako_garam_dapur.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 250)),
      updatedAt: DateTime.now(),
    ),

    // =========================================================================
    // KATEGORI 6: KEBUTUHAN (10 Produk dari folder Produk/Kebutuhan)
    // =========================================================================
    ProductModel(
      id: 'prod-51',
      sku: 'KBT-001',
      name: 'Sabun Mandi Cair',
      categoryId: 'cat-6',
      categoryName: 'Kebutuhan',
      price: 24000,
      stock: 40,
      description:
          'Sabun mandi cair antibakteri lembut di kulit dengan keharuman segar tahan lama.',
      images: const ['assets/produk/kebutuhan_sabun_mandi_cair.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 255)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-52',
      sku: 'KBT-002',
      name: 'Shampoo Botol',
      categoryId: 'cat-6',
      categoryName: 'Kebutuhan',
      price: 26500,
      stock: 34,
      description:
          'Shampoo perawatan rambut lembut berkilau anti ketombe kemasan botol praktis.',
      images: const ['assets/produk/kebutuhan_shampoo_botol.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 260)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-53',
      sku: 'KBT-003',
      name: 'Deterjen Bubuk',
      categoryId: 'cat-6',
      categoryName: 'Kebutuhan',
      price: 21000,
      stock: 44,
      description:
          'Deterjen bubuk konsentrat ampuh angkat noda membandel dan menjaga warna pakaian.',
      images: const ['assets/produk/kebutuhan_deterjen_bubuk.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 265)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-54',
      sku: 'KBT-004',
      name: 'Pencuci Piring',
      categoryId: 'cat-6',
      categoryName: 'Kebutuhan',
      price: 14500,
      stock: 56,
      description:
          'Cairan pencuci piring ekstrak jeruk nipis penghilang lemak membandel dengan cepat.',
      images: const ['assets/produk/kebutuhan_pencuci_piring.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 270)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-55',
      sku: 'KBT-005',
      name: 'Pewangi Pakaian',
      categoryId: 'cat-6',
      categoryName: 'Kebutuhan',
      price: 16000,
      stock: 48,
      description:
          'Pelembut dan pewangi pakaian konsentrat dengan keharuman floral segar sepanjang hari.',
      images: const ['assets/produk/kebutuhan_pewangi_pakaian.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 275)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-56',
      sku: 'KBT-006',
      name: 'Pasta Gigi',
      categoryId: 'cat-6',
      categoryName: 'Kebutuhan',
      price: 12500,
      stock: 64,
      description:
          'Pasta gigi berfluoride dengan ekstrak mint segar untuk perlindungan gigi berlubang.',
      images: const ['assets/produk/kebutuhan_pasta_gigi.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 280)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-57',
      sku: 'KBT-007',
      name: 'Pembersih Lantai',
      categoryId: 'cat-6',
      categoryName: 'Kebutuhan',
      price: 15500,
      stock: 38,
      description:
          'Cairan pembersih lantai antibakteri dengan aroma pinus segar dan bebas lengket.',
      images: const ['assets/produk/kebutuhan_pembersih_lantai.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 285)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-58',
      sku: 'KBT-008',
      name: 'Sabun Batang',
      categoryId: 'cat-6',
      categoryName: 'Kebutuhan',
      price: 6500,
      stock: 80,
      description:
          'Sabun mandi batang antiseptik dengan pelembap alami untuk perlindungan kulit setiap hari.',
      images: const ['assets/produk/kebutuhan_sabun_batang.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 290)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-59',
      sku: 'KBT-009',
      name: 'Sikat Gigi',
      categoryId: 'cat-6',
      categoryName: 'Kebutuhan',
      price: 9500,
      stock: 70,
      description:
          'Sikat gigi bulu halus ujung tipis menjangkau sela-sela gigi dengan gagang ergonomis.',
      images: const ['assets/produk/kebutuhan_sikat_gigi.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 295)),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod-60',
      sku: 'KBT-010',
      name: 'Tisu Kotak',
      categoryId: 'cat-6',
      categoryName: 'Kebutuhan',
      price: 11500,
      stock: 54,
      description:
          'Tisu wajah 2 ply ekstra lembut dari serat alami 250 lembar dalam kemasan kotak rapi.',
      images: const ['assets/produk/kebutuhan_tisu_kotak.jpg'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 300)),
      updatedAt: DateTime.now(),
    ),
  ];

  static List<ProductModel> get demoProductsRef => _demoProducts;

  Future<List<ProductModel>> fetchProducts() async {
    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      try {
        final response = await client
            .from('products')
            .select('*, categories(name)')
            .order('created_at', ascending: false);
        return (response as List)
            .map((item) => ProductModel.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    // Database Lokal Terintegrasi & Permanen
    return await _localDb.getProducts();
  }

  Future<ProductModel> createProduct(
    ProductModel product, {
    required bool isAdmin,
  }) async {
    if (!isAdmin) {
      throw Exception('Akses ditolak: Hanya Admin yang dapat menambah produk.');
    }
    if (product.name.trim().isEmpty) {
      throw Exception('Nama produk tidak boleh kosong.');
    }
    if (product.price < 0 || product.stock < 0) {
      throw Exception('Harga dan stok tidak boleh bernilai negatif.');
    }

    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      try {
        final res = await client
            .from('products')
            .insert(product.toMap())
            .select('*, categories(name)')
            .single();
        return ProductModel.fromMap(res);
      } catch (e) {
        throw Exception('Gagal menyimpan ke cloud: ${e.toString()}');
      }
    }

    // Simpan permanen ke Database Lokal
    return await _localDb.addProduct(product);
  }

  Future<ProductModel> updateProduct(
    ProductModel product, {
    required bool isAdmin,
  }) async {
    if (!isAdmin) {
      throw Exception('Akses ditolak: Hanya Admin yang dapat mengubah produk.');
    }
    if (product.name.trim().isEmpty) {
      throw Exception('Nama produk tidak boleh kosong.');
    }
    if (product.price < 0 || product.stock < 0) {
      throw Exception('Harga dan stok tidak boleh bernilai negatif.');
    }

    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      try {
        final res = await client
            .from('products')
            .update(product.toMap())
            .eq('id', product.id)
            .select('*, categories(name)')
            .single();
        return ProductModel.fromMap(res);
      } catch (e) {
        throw Exception('Gagal memperbarui ke cloud: ${e.toString()}');
      }
    }

    // Update permanen ke Database Lokal
    return await _localDb.updateProduct(product);
  }

  Future<void> deleteProduct(String id, {required bool isAdmin}) async {
    if (!isAdmin) {
      throw Exception('Akses ditolak: Hanya Admin yang dapat menghapus produk.');
    }
    final client = SupabaseConfig.clientOrNull;
    if (client != null) {
      try {
        await client.from('products').delete().eq('id', id);
        return;
      } catch (e) {
        throw Exception('Gagal menghapus dari cloud: ${e.toString()}');
      }
    }

    // Hapus permanen dari Database Lokal
    await _localDb.deleteProduct(id);
  }
}
