import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/custom_cached_image.dart';
import '../../core/widgets/smooth_staggered_reveal.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/product_card.dart';
import '../products/product_detail_swipe_screen.dart';
import '../products/product_form_screen.dart';
import 'receipt_dialog.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _amountPaidController = TextEditingController();
  String _selectedPaymentMethod = 'Cash';
  bool _showMobileCartView = false;

  @override
  void dispose() {
    _customerController.dispose();
    _amountPaidController.dispose();
    super.dispose();
  }

  int _getEnteredAmountPaid(int total) {
    if (_selectedPaymentMethod != 'Cash') return total;
    final clean = _amountPaidController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? total;
  }

  Future<void> _handleCheckout() async {
    final cart = context.read<CartProvider>();
    if (cart.isEmpty) return;

    final total = cart.total;
    final paid = _getEnteredAmountPaid(total);

    if (paid < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Uang diterima (${CurrencyFormatter.formatRupiah(paid)}) kurang dari total (${CurrencyFormatter.formatRupiah(total)}).',
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final txProvider = context.read<TransactionProvider>();
    final productProvider = context.read<ProductProvider>();

    final createdTx = await txProvider.checkout(
      customerName: _customerController.text,
      paymentMethod: _selectedPaymentMethod,
      amountPaid: paid,
      items: cart.items,
      userId: auth.currentUser?.id ?? 'demo-admin-001',
    );

    if (!mounted) return;

    if (createdTx != null) {
      cart.clearCart();
      _customerController.clear();
      _amountPaidController.clear();
      setState(() => _showMobileCartView = false);
      await productProvider.loadProducts();

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => ReceiptDialog(transaction: createdTx),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            txProvider.errorMessage ?? 'Gagal memproses transaksi.',
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktopSplit = constraints.maxWidth >= 720;

        if (isDesktopSplit) {
          return Scaffold(
            backgroundColor: const Color(0xFFFAF9F6),
            body: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: _buildProductSelectionArea(),
                  ),
                  Container(
                    width: 1,
                    color: AppColors.borderLight,
                  ),
                  SizedBox(
                    width: 360,
                    child: _buildCartAndCheckoutPanel(),
                  ),
                ],
              ),
            ),
          );
        }

        final cart = context.watch<CartProvider>();
        return Scaffold(
          backgroundColor: const Color(0xFFFAF9F6),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                SmoothStaggeredReveal(
                  index: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Kasir / POS UMKM',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDarkSlate,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              _buildMobileViewToggle(
                                label: 'Produk',
                                active: !_showMobileCartView,
                                onTap: () => setState(
                                  () => _showMobileCartView = false,
                                ),
                              ),
                              _buildMobileViewToggle(
                                label: 'Keranjang (${cart.totalItemsCount})',
                                active: _showMobileCartView,
                                onTap: () =>
                                    setState(() => _showMobileCartView = true),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _showMobileCartView
                      ? _buildCartAndCheckoutPanel()
                      : Stack(
                          children: [
                            _buildProductSelectionArea(hideHeader: true),
                            if (!cart.isEmpty)
                              Positioned(
                                left: 18,
                                right: 18,
                                bottom: 86,
                                child: GestureDetector(
                                  onTap: () => setState(
                                    () => _showMobileCartView = true,
                                  ),
                                  child: Container(
                                    height: 52,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.textDarkSlate,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x40000000),
                                          blurRadius: 16,
                                          offset: Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.posOrange,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '${cart.totalItemsCount} Item',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              CurrencyFormatter.formatRupiah(
                                                cart.total,
                                              ),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Row(
                                          children: [
                                            Text(
                                              'Lanjut Bayar',
                                              style: TextStyle(
                                                color: AppColors.posOrange,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 16,
                                              color: AppColors.posOrange,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileViewToggle({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: active ? AppColors.posOrange : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildProductSelectionArea({bool hideHeader = false}) {
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.read<CartProvider>();
    final products = productProvider.filteredProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hideHeader)
          const SmoothStaggeredReveal(
            index: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 14, 18, 6),
              child: Text(
                'Pilih Produk Kasir (POS)',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDarkSlate,
                ),
              ),
            ),
          ),
        SmoothStaggeredReveal(
          index: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: productProvider.setSearchQuery,
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'Cari produk atau scan SKU...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductFormScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.posOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text(
                    'Barang',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 140),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 210,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final prod = products[index];
              return SmoothStaggeredReveal(
                key: ValueKey(
                  'pos_card_${prod.id}_${productProvider.catalogVersion}',
                ),
                index: index + 2,
                child: ProductCard(
                  product: prod,
                  onTapDetail: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailSwipeScreen(initialProduct: prod),
                      ),
                    );
                  },
                  onTapAddToCart: () {
                    final err = cartProvider.addToCart(prod);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(milliseconds: 1100),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: err != null
                            ? AppColors.errorRed
                            : AppColors.loginPrimaryGreen,
                        content: Text(
                          err ?? '+1 ${prod.name} masuk keranjang kasir',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartAndCheckoutPanel() {
    final cart = context.watch<CartProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final total = cart.total;
    final paid = _getEnteredAmountPaid(total);
    final change = paid >= total ? paid - total : 0;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ringkasan Pesanan (${cart.totalItemsCount})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDarkSlate,
                  ),
                ),
                if (!cart.isEmpty)
                  TextButton(
                    onPressed: cart.clearCart,
                    child: const Text(
                      'Kosongkan',
                      style: TextStyle(
                        color: AppColors.errorRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: cart.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 48,
                          color: Color(0xFFCBD5E1),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Keranjang kasir masih kosong',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return SmoothStaggeredReveal(
                        index: index,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              CustomProductImage(
                                imageUrl: item.product.primaryImage,
                                width: 48,
                                height: 48,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      '${item.selectedVariant} • ${CurrencyFormatter.formatRupiah(item.unitPrice)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.formatRupiah(
                                        item.subtotal,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.posOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  _buildQtyBtn(
                                    icon: Icons.remove_rounded,
                                    onTap: () => cart.decrementQuantity(index),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ),
                                  _buildQtyBtn(
                                    icon: Icons.add_rounded,
                                    isOrange: true,
                                    onTap: () {
                                      final err = cart.incrementQuantity(index);
                                      if (err != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(err),
                                            backgroundColor: AppColors.errorRed,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => cart.removeItem(index),
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: AppColors.errorRed,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: TextField(
                          controller: _customerController,
                          style: const TextStyle(fontSize: 12.5),
                          decoration: InputDecoration(
                            hintText: 'Nama Pelanggan (Opsional)',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: AppConstants.paymentMethods.map((method) {
                        final selected = _selectedPaymentMethod == method;
                        return Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: ChoiceChip(
                            label: Text(
                              method,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textDarkSlate,
                              ),
                            ),
                            selected: selected,
                            selectedColor: AppColors.posOrange,
                            onSelected: (_) {
                              setState(() => _selectedPaymentMethod = method);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                if (_selectedPaymentMethod == 'Cash' && !cart.isEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: TextField(
                            controller: _amountPaidController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(fontSize: 12.5),
                            decoration: InputDecoration(
                              hintText: 'Uang diterima (Default: Uang Pas)',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _buildQuickCashChip('Pas', total),
                      const SizedBox(width: 4),
                      _buildQuickCashChip('50rb', 50000),
                      const SizedBox(width: 4),
                      _buildQuickCashChip('100rb', 100000),
                    ],
                  ),
                ],

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatRupiah(total),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDarkSlate,
                      ),
                    ),
                  ],
                ),
                if (_selectedPaymentMethod == 'Cash' && !cart.isEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estimasi Kembalian',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatRupiah(change),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.loginPrimaryGreen,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: (cart.isEmpty || txProvider.isLoading)
                        ? null
                        : _handleCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.posOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: Text(
                      txProvider.isLoading
                          ? 'Memproses...'
                          : 'Commander • Bayar (${CurrencyFormatter.formatRupiah(total)})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool isOrange = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: isOrange ? AppColors.posOrange : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isOrange ? AppColors.posOrange : AppColors.borderLight,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: isOrange ? Colors.white : AppColors.textDarkSlate,
        ),
      ),
    );
  }

  Widget _buildQuickCashChip(String label, int amount) {
    return InkWell(
      onTap: () {
        setState(() {
          _amountPaidController.text = amount.toString();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.posOrangeLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.posOrange,
          ),
        ),
      ),
    );
  }
}
