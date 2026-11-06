import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get todaySalesTotal {
    final now = DateTime.now();
    return _transactions
        .where(
          (tx) =>
              tx.createdAt.year == now.year &&
              tx.createdAt.month == now.month &&
              tx.createdAt.day == now.day,
        )
        .fold<int>(0, (sum, tx) => sum + tx.total);
  }

  int get todayTransactionsCount {
    final now = DateTime.now();
    return _transactions
        .where(
          (tx) =>
              tx.createdAt.year == now.year &&
              tx.createdAt.month == now.month &&
              tx.createdAt.day == now.day,
        )
        .length;
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _transactions = await _transactionService.fetchTransactions();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TransactionModel?> checkout({
    required String customerName,
    required String paymentMethod,
    required int amountPaid,
    required List<CartItemModel> items,
    required String userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final created = await _transactionService.processCheckout(
        customerName: customerName,
        paymentMethod: paymentMethod,
        amountPaid: amountPaid,
        items: items,
        userId: userId,
      );
      _transactions = [created, ..._transactions];
      _isLoading = false;
      notifyListeners();
      return created;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
