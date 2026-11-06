import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_cached_image.dart';
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
      text: p != null ? p.price.toString() : '',
    );
    _stockController = TextEditingController(
      text: p != null ? p.stock.toString() : '20',
    );
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _imageUrlController = TextEditingController();
    _selectedCategoryId = p?.categoryId;
    _galleryUrls = p != null ? List<String>.from(p.images) : [];
  }

  @override
  void dispose() {
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
        imageQuality: 82,
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
        _galleryUrls.add(uploadedUrl);
        _isUploadingImage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gambar berhasil diunggah ke Cloud Storage.'),
          backgroundColor: AppColors.loginPrimaryGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
          content: Text(err ?? 'Masukkan URL gambar yang valid.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    setState(() {
      _galleryUrls.add(url);
      _imageUrlController.clear();
    });
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
      categoryName: catObj?.name ?? 'Umum',
      price: int.parse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), '')),
      stock: int.parse(_stockController.text.replaceAll(RegExp(r'[^0-9]'), '')),
      description: _descriptionController.text.trim().isEmpty
          ? 'Produk UMKM unggulan siap jual.'
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
          content: Text(
            isEditMode
                ? 'Produk "${productModel.name}" berhasil diperbarui!'
                : 'Produk "${productModel.name}" berhasil ditambahkan!',
          ),
          backgroundColor: AppColors.loginPrimaryGreen,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            productProvider.errorMessage ?? 'Gagal menyimpan produk.',
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

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Produk UMKM' : 'Tambah Produk Baru',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Galeri & Upload Gambar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Foto & Galeri Produk',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: AppColors.textDarkSlate,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _isUploadingImage ? null : _pickAndUploadImage,
                    icon: _isUploadingImage
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.upload_file_rounded,
                            size: 16,
                            color: AppColors.posOrange,
                          ),
                    label: Text(
                      _isUploadingImage
                          ? 'Mengunggah...'
                          : 'Upload Foto dari Perangkat',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.posOrange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (_galleryUrls.isNotEmpty)
                SizedBox(
                  height: 94,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _galleryUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          CustomProductImage(
                            imageUrl: _galleryUrls[index],
                            width: 94,
                            height: 94,
                            borderRadius: BorderRadius.circular(14),
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
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                        hintText: 'Tempel URL Gambar (https://...)',
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
                    icon: const Icon(Icons.add_photo_alternate_rounded),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filledTonal(
                    onPressed: _isUploadingImage ? null : _pickAndUploadImage,
                    icon: _isUploadingImage
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Nama Produk
              TextFormField(
                controller: _nameController,
                validator: (v) => Validators.validateRequired(v, 'Nama produk'),
                decoration: const InputDecoration(
                  labelText: 'Nama Produk *',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
              ),
              const SizedBox(height: 12),

              // SKU & Kategori
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _skuController,
                      validator: (v) => Validators.validateRequired(v, 'SKU'),
                      decoration: const InputDecoration(
                        labelText: 'Kode SKU Unik *',
                        prefixIcon: Icon(Icons.qr_code_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      items: categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(
                                c.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() => _selectedCategoryId = val);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Kategori *',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Harga & Stok
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          Validators.validateNonNegativeInt(v, 'Harga'),
                      decoration: const InputDecoration(
                        labelText: 'Harga (Rp) *',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          Validators.validateNonNegativeInt(v, 'Stok'),
                      decoration: const InputDecoration(
                        labelText: 'Stok Unit *',
                        prefixIcon: Icon(Icons.layers_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Deskripsi
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Produk',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.posOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    _isSaving
                        ? 'Menyimpan...'
                        : (isEditMode ? 'Simpan Perubahan' : 'Tambah Produk'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
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

