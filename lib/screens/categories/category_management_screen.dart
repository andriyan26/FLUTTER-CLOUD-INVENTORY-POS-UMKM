import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/category_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _showCategoryDialog({CategoryModel? existing}) async {
    _nameController.text = existing?.name ?? '';
    final isEdit = existing != null;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori Baru'),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Contoh: Minuman Kopi & Teh',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.posOrange,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (saved != true || !mounted) return;
    final isAdmin = context.read<AuthProvider>().isAdmin;
    final catProvider = context.read<CategoryProvider>();

    final bool ok = isEdit
        ? await catProvider.editCategory(
            existing.id,
            _nameController.text,
            isAdmin: isAdmin,
          )
        : await catProvider.addCategory(
            _nameController.text,
            isAdmin: isAdmin,
          );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Kategori berhasil disimpan.'
              : (catProvider.errorMessage ?? 'Gagal menyimpan kategori.'),
        ),
        backgroundColor:
            ok ? AppColors.loginPrimaryGreen : AppColors.errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final productProvider = context.watch<ProductProvider>();
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Manajemen Kategori UMKM',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        actions: [
          if (isAdmin)
            IconButton(
              onPressed: () => _showCategoryDialog(),
              icon: const Icon(Icons.add_circle_rounded,
                  color: AppColors.posOrange),
              tooltip: 'Tambah Kategori',
            ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categoryProvider.categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final cat = categoryProvider.categories[index];
          final count = productProvider.countProductsByCategory(cat.id);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.posOrangeLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.category_rounded,
                    color: AppColors.posOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          color: AppColors.textDarkSlate,
                        ),
                      ),
                      Text(
                        '$count produk terhubung',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAdmin) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 19),
                    onPressed: () => _showCategoryDialog(existing: cat),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 19,
                      color: AppColors.errorRed,
                    ),
                    onPressed: () async {
                      final ok = await categoryProvider.removeCategory(
                        cat.id,
                        linkedProductCount: count,
                        isAdmin: isAdmin,
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? 'Kategori "${cat.name}" dihapus.'
                                : (categoryProvider.errorMessage ??
                                    'Gagal menghapus kategori.'),
                          ),
                          backgroundColor: ok
                              ? AppColors.loginPrimaryGreen
                              : AppColors.errorRed,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

