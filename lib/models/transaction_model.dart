class TransactionDetailModel {
  final String id;
  final String transactionId;
  final String productId;
  final String productName;
  final int price;
  final int quantity;
  final int subtotal;

  const TransactionDetailModel({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory TransactionDetailModel.fromMap(Map<String, dynamic> map) {
    return TransactionDetailModel(
      id: (map['id'] ?? '').toString(),
      transactionId: (map['transaction_id'] ?? '').toString(),
      productId: (map['product_id'] ?? '').toString(),
      productName: (map['product_name'] ?? '').toString(),
      price: int.tryParse((map['price'] ?? 0).toString()) ?? 0,
      quantity: int.tryParse((map['quantity'] ?? 1).toString()) ?? 1,
      subtotal: int.tryParse((map['subtotal'] ?? 0).toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}

class TransactionModel {
  final String id;
  final String transactionCode;
  final String customerName;
  final int subtotal;
  final int total;
  final String paymentMethod;
  final int amountPaid;
  final int changeAmount;
  final String userId;
  final DateTime createdAt;
  final List<TransactionDetailModel> details;

  const TransactionModel({
    required this.id,
    required this.transactionCode,
    required this.customerName,
    required this.subtotal,
    required this.total,
    required this.paymentMethod,
    required this.amountPaid,
    required this.changeAmount,
    required this.userId,
    required this.createdAt,
    this.details = const [],
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    final rawDetails = map['transaction_details'];
    final List<TransactionDetailModel> parsedDetails = [];
    if (rawDetails is List) {
      for (final d in rawDetails) {
        if (d is Map<String, dynamic>) {
          parsedDetails.add(TransactionDetailModel.fromMap(d));
        }
      }
    }

    return TransactionModel(
      id: (map['id'] ?? '').toString(),
      transactionCode: (map['transaction_code'] ?? '').toString(),
      customerName: (map['customer_name'] ?? 'Pelanggan Umum').toString(),
      subtotal: int.tryParse((map['subtotal'] ?? 0).toString()) ?? 0,
      total: int.tryParse((map['total'] ?? 0).toString()) ?? 0,
      paymentMethod: (map['payment_method'] ?? 'Cash').toString(),
      amountPaid: int.tryParse((map['amount_paid'] ?? 0).toString()) ?? 0,
      changeAmount: int.tryParse((map['change_amount'] ?? 0).toString()) ?? 0,
      userId: (map['user_id'] ?? '').toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      details: parsedDetails,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_code': transactionCode,
      'customer_name': customerName,
      'subtotal': subtotal,
      'total': total,
      'payment_method': paymentMethod,
      'amount_paid': amountPaid,
      'change_amount': changeAmount,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'transaction_details': details.map((d) => d.toMap()).toList(),
    };
  }
}

