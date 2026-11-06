import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/smooth_staggered_reveal.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../pos/receipt_dialog.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _searchQuery = '';
  String _dateFilter = 'Semua';

  List<TransactionModel> _applyFilters(List<TransactionModel> all) {
    final now = DateTime.now();
    return all.where((tx) {
      if (_dateFilter == 'Hari Ini') {
        final sameDay = tx.createdAt.year == now.year &&
            tx.createdAt.month == now.month &&
            tx.createdAt.day == now.day;
        if (!sameDay) return false;
      } else if (_dateFilter == '7 Hari') {
        if (now.difference(tx.createdAt).inDays > 7) return false;
      } else if (_dateFilter == 'Bulan Ini') {
        if (now.difference(tx.createdAt).inDays > 30) {
          return false;
        }
      }

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        return tx.transactionCode.toLowerCase().contains(q) ||
            tx.customerName.toLowerCase().contains(q) ||
            tx.paymentMethod.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final filtered = _applyFilters(txProvider.transactions);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SmoothStaggeredReveal(
              index: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 12, 18, 8),
                child: Text(
                  'Riwayat Transaksi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDarkSlate,
                  ),
                ),
              ),
            ),

            SmoothStaggeredReveal(
              index: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
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
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            hintText:
                                'Cari nomor transaksi (INV-...) atau pelanggan...',
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
            ),

            const SizedBox(height: 10),

            SmoothStaggeredReveal(
              index: 2,
              child: SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  children: ['Semua', 'Hari Ini', '7 Hari', 'Bulan Ini']
                      .map((period) {
                    final active = _dateFilter == period;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _dateFilter = period),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: active ? AppColors.posOrange : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: active
                                  ? AppColors.posOrange
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Text(
                            period,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? Colors.white
                                  : AppColors.textDarkSlate,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada riwayat transaksi pada periode ini.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final tx = filtered[index];
                        return SmoothStaggeredReveal(
                          key: ValueKey('tx_${tx.id}_$_dateFilter'),
                          index: index + 2,
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => ReceiptDialog(transaction: tx),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: AppColors.borderLight),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x060F172A),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        tx.transactionCode,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13.5,
                                          color: AppColors.textDarkSlate,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.loginSoftMint,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'LUNAS • ${tx.paymentMethod}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.loginPrimaryGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tx.customerName,
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            CurrencyFormatter.formatDateTime(
                                              tx.createdAt,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            CurrencyFormatter.formatRupiah(
                                              tx.total,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.posOrange,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 9,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.posOrangeLight,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(
                                                  Icons.print_rounded,
                                                  size: 13,
                                                  color: AppColors.posOrange,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Struk',
                                                  style: TextStyle(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w800,
                                                    color:
                                                        AppColors.posOrangeDark,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
