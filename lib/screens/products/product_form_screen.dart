import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_cached_image.dart';
import '../../core/widgets/smooth_staggered_reveal.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/storage_service.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? existingProduct;

  const ProductFormScreen({
    super.key,
    this.existingProduct,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final StorageService _storageService = StorageService();

  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;

  String? _selectedCategoryId;
  List<String> _galleryUrls = [];
  bool _isUploadingImage = false;
  bool _isSaving = false;

  bool get isEditMode => widget.existingProduct != null;

  static const List<Map<String, String>> _studioProductPhotos = [
    {
      'label': 'Kopi Susu',
      'url':
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80',
    },
    {
      'label': 'Burger / Kuliner',
      'url':
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80',
    },
    {
      'label': 'Croissant / Roti',
      'url':
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=600&q=80',
    },
    {
      'label': 'Minuman Segar',
      'url':
          'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
    },
    {
      'label': 'Matcha Latte',
      'url':
          'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=600&q=80',
    },
    {
      'label': 'Paket Sembako',
      'url':
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=600&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    _nameController = TextEditingController(text: p?.name ?? '');
    _skuController = TextEditingController(
      text: p?.sku ??
          'UMKM-${(DateTime.now().millisecondsSinceEpoch % 900 + 100)}',
    );
    _priceController = TextEditingController(
      text: p != null ? p.price.toString() : '18000',
    );
    _stockController = TextEditingController(
      text: p != null ? p.stock.toString() : '25',
    );
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _imageUrlController = TextEditingController();
    _selectedCategoryId = p?.categoryId;
    _galleryUrls = p != null ? List<String>.from(p.images) : [];

    _nameController.addListener(_onLiveFieldChanged);
    _skuController.addListener(_onLiveFieldChanged);
    _priceController.addListener(_onLiveFieldChanged);
    _stockController.addListener(_onLiveFieldChanged);
  }

  void _onLiveFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onLiveFieldChanged);
    _skuController.removeListener(_onLiveFieldChanged);
    _priceController.removeListener(_onLiveFieldChanged);
    _stockController.removeListener(_onLiveFieldChanged);
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 84,
      );
      if (picked == null) return;

      setState(() => _isUploadingImage = true);
      final bytes = await picked.readAsBytes();
      final uploadedUrl = await _storageService.uploadProductImage(
        bytes: bytes,
        fileName: picked.name,
      );

      if (!mounted) return;
      setState(() {
        _galleryUrls.insert(0, uploadedUrl);
        _isUploadingImage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.loginPrimaryGreen,
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gambar barang berhasil diunggah & dijadikan Foto Utama!',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _addImageUrl() {
    final url = _imageUrlController.text.trim();
    final err = Validators.validateImageUrl(url);
    if (url.isEmpty || err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(err ?? 'Masukkan URL gambar yang valid.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    setState(() {
      _galleryUrls.insert(0, url);
      _imageUrlController.clear();
    });
  }

  void _adjustStock(int delta) {
    final current =
        int.tryParse(_stockController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
            0;
    final next = (current + delta).clamp(0, 99999);
    _stockController.text = next.toString();
  }

  Future<void> _showAddCategoryQuickDialog() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Tambah Kategori Baru',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nama Kategori UMKM',
            hintText: 'Contoh: Dessert & Es Krim',
            prefixIcon: Icon(Icons.category_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.posOrange,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Simpan Kategori'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      final catProvider = context.read<CategoryProvider>();
      final ok = await catProvider.addCategory(
        result,
        isAdmin: true,
      );
      if (ok && mounted && catProvider.categories.isNotEmpty) {
        setState(() {
          _selectedCategoryId = catProvider.categories.last.id;
        });
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final categories = context.read<CategoryProvider>().categories;
    final catId = _selectedCategoryId ??
        (categories.isNotEmpty ? categories.first.id : 'cat-1');
    final catObj = categories.where((c) => c.id == catId).firstOrNull;

    final images = _galleryUrls.isNotEmpty
        ? _galleryUrls
        : [
            'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80',
          ];

    setState(() => _isSaving = true);

    final productModel = ProductModel(
      id: widget.existingProduct?.id ?? '',
      sku: _skuController.text.trim().toUpperCase(),
      name: _nameController.text.trim(),
      categoryId: catId,
      categoryName: catObj?.name ?? 'Minuman & Kopi',
      price: int.tryParse(
            _priceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0,
      stock: int.tryParse(
            _stockController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0,
      description: _descriptionController.text.trim().isEmpty
          ? 'Produk UMKM unggulan siap jual kualitas terbaik.'
          : _descriptionController.text.trim(),
      images: images,
      createdAt: widget.existingProduct?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final isAdmin = context.read<AuthProvider>().isAdmin;
    final productProvider = context.read<ProductProvider>();
    final bool ok = isEditMode
        ? await productProvider.updateProduct(productModel, isAdmin: isAdmin)
        : await productProvider.addProduct(productModel, isAdmin: isAdmin);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.loginPrimaryGreen,
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEditMode
                      ? 'Barang "${productModel.name}" berhasil diperbarui!'
                      : 'Barang "${productModel.name}" berhasil ditambahkan & langsung tampil di urutan #1!',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            productProvider.errorMessage ?? 'Gagal menyimpan barang.',
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    final selectedCatObj =
        categories.where((c) => c.id == _selectedCategoryId).firstOrNull;
    final previewName = _nameController.text.trim().isEmpty
        ? 'Nama Barang Baru Anda'
        : _nameController.text.trim();
    final previewPrice = int.tryParse(
          _priceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    final previewStock = int.tryParse(
          _stockController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    final previewImage = _galleryUrls.isNotEmpty
        ? _galleryUrls.first
        : 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          isEditMode ? 'Edit Barang UMKM' : 'Tambah Barang Baru UMKM',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16.5),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 36),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. LIVE PREVIEW KARTU BARANG SECARA REAL-TIME
              SmoothStaggeredReveal(
                index: 0,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF153423), Color(0xFF234F35)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26153423),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Mini Gambar Preview
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: CustomProductImage(
                              imageUrl: previewImage,
                              width: 78,
                              height: 78,
                              borderRadius: BorderRadius.circular(16),
                              fallbackLabel: previewName,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.posOrange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'BARU ✨',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'PRATINJAU OTOMATIS DI KATALOG',
                                style: TextStyle(
                                  color: Color(0xFFBEF264),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              previewName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${selectedCatObj?.name ?? 'Minuman & Kopi'} • ${_skuController.text.toUpperCase()}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFD1FAE5),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  CurrencyFormatter.formatRupiah(previewPrice),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.loginPrimaryGreen,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Stok $previewStock Unit',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 2. STUDIO UPLOAD GAMBAR BARANG (DARI LAPTOP / HP ATAU GALERI CEPAT)
              SmoothStaggeredReveal(
                index: 1,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.add_photo_alternate_rounded,
                            color: AppColors.posOrange,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Upload Foto Barang (Dari Laptop / HP)',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: AppColors.textDarkSlate,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Dropzone Tombol Besar Upload Gambar dari Perangkat
                      InkWell(
                        onTap: _isUploadingImage ? null : _pickAndUploadImage,
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7F4),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color:
                                  AppColors.posOrange.withValues(alpha: 0.45),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              if (_isUploadingImage)
                                const SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.posOrange,
                                  ),
                                )
                              else
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: AppColors.posOrange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.cloud_upload_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                _isUploadingImage
                                    ? 'Sedang Mengunggah Gambar Barang...'
                                    : 'Klik untuk Pilih & Upload Foto dari Perangkat',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.posOrangeDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Mendukung JPG, PNG, WEBP dari Laptop / Galeri HP',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Daftar Gambar yang Sudah Diunggah
                      if (_galleryUrls.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Foto Barang Terpilih (Ketuk untuk Jadikan Utama):',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDarkSlate,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 86,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _galleryUrls.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final isPrimary = index == 0;
                              return GestureDetector(
                                onTap: () {
                                  if (index > 0) {
                                    setState(() {
                                      final picked =
                                          _galleryUrls.removeAt(index);
                                      _galleryUrls.insert(0, picked);
                                    });
                                  }
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isPrimary
                                              ? AppColors.loginPrimaryGreen
                                              : AppColors.borderLight,
                                          width: isPrimary ? 2.2 : 1,
                                        ),
                                      ),
                                      child: CustomProductImage(
                                        imageUrl: _galleryUrls[index],
                                        width: 80,
                                        height: 80,
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                    ),
                                    if (isPrimary)
                                      Positioned(
                                        bottom: 4,
                                        left: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.loginPrimaryGreen,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'UTAMA',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _galleryUrls.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: const BoxDecoration(
                                            color: Colors.black87,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close_rounded,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),
                      const Text(
                        'Atau Pilih Cepat Foto Studio UMKM (1-Klik):',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 64,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _studioProductPhotos.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, idx) {
                            final item = _studioProductPhotos[idx];
                            final url = item['url']!;
                            final label = item['label']!;
                            final isSelected =
                                _galleryUrls.isNotEmpty && _galleryUrls.first == url;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _galleryUrls.remove(url);
                                  _galleryUrls.insert(0, url);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.posOrangeLight
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.posOrange
                                        : AppColors.borderLight,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CustomProductImage(
                                      imageUrl: url,
                                      width: 48,
                                      height: 48,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    const SizedBox(width: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: isSelected
                                              ? AppColors.posOrangeDark
                                              : AppColors.textDarkSlate,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _imageUrlController,
                              decoration: const InputDecoration(
                                hintText:
                                    'Atau tempel link URL gambar (https://...)',
                                prefixIcon: Icon(Icons.link_rounded, size: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _addImageUrl,
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.posOrange,
                            ),
                            icon: const Icon(Icons.add_rounded),
                            tooltip: 'Tambahkan URL Gambar',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3. DETAIL INFORMASI BARANG, KATEGORI, HARGA & STOK
              SmoothStaggeredReveal(
                index: 2,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi & Detail Barang UMKM',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppColors.textDarkSlate,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Nama Barang
                      TextFormField(
                        controller: _nameController,
                        validator: (v) =>
                            Validators.validateRequired(v, 'Nama barang'),
                        decoration: const InputDecoration(
                          labelText: 'Nama Barang UMKM *',
                          hintText: 'Contoh: Es Kopi Susu Aren Spesial',
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Pilih Kategori + Tombol Tambah Kategori Baru
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pilih Kategori Barang *',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDarkSlate,
                            ),
                          ),
                          InkWell(
                            onTap: _showAddCategoryQuickDialog,
                            child: const Text(
                              '+ Buat Kategori Baru',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.posOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: categories.map((cat) {
                          final selected = _selectedCategoryId == cat.id;
                          return ChoiceChip(
                            label: Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textDarkSlate,
                              ),
                            ),
                            selected: selected,
                            selectedColor: AppColors.posOrange,
                            onSelected: (_) =>
                                setState(() => _selectedCategoryId = cat.id),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 12),

                      // SKU & Harga Jual
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _skuController,
                              validator: (v) =>
                                  Validators.validateRequired(v, 'Kode SKU'),
                              decoration: InputDecoration(
                                labelText: 'Kode SKU Unik *',
                                prefixIcon:
                                    const Icon(Icons.qr_code_2_rounded),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _skuController.text =
                                          'UMKM-${DateTime.now().millisecondsSinceEpoch % 900 + 100}';
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 18,
                                  ),
                                  tooltip: 'Acak SKU Baru',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              validator: (v) => Validators.validateNonNegativeInt(
                                v,
                                'Harga',
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Harga Jual (Rp) *',
                                prefixIcon: Icon(Icons.payments_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      // Quick Price Preset Chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [10000, 15000, 18000, 25000, 35000, 50000]
                            .map((val) {
                          return InkWell(
                            onTap: () => setState(
                              () => _priceController.text = val.toString(),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                CurrencyFormatter.formatRupiah(val),
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDarkSlate,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 14),

                      // Stok Unit dengan Stepper - / +
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              validator: (v) => Validators.validateNonNegativeInt(
                                v,
                                'Stok',
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Jumlah Stok Gudang (Unit) *',
                                prefixIcon: Icon(Icons.layers_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            onPressed: () => _adjustStock(-5),
                            icon: const Icon(Icons.remove_rounded),
                            tooltip: 'Kurangi 5',
                          ),
                          const SizedBox(width: 4),
                          IconButton.filled(
                            onPressed: () => _adjustStock(5),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.loginPrimaryGreen,
                            ),
                            icon: const Icon(Icons.add_rounded),
                            tooltip: 'Tambah 5',
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Deskripsi Barang
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi Barang (Tampil di Detail Swipe)',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:
                                const BorderSide(color: AppColors.borderLight),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 4. TOMBOL SIMPAN & TAMPILKAN OTOMATIS
              SmoothStaggeredReveal(
                index: 3,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.posOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_rounded, size: 20),
                    label: Text(
                      _isSaving
                          ? 'Menyimpan Barang...'
                          : (isEditMode
                              ? 'Simpan Perubahan Barang'
                              : 'Simpan & Tampilkan Barang Sekarang'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
