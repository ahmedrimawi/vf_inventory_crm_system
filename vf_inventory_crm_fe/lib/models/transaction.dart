class TransactionItem {
  final String id;
  final String productId;
  final double quantity;
  final double unitPrice;
  final double totalPrice;

  TransactionItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      quantity: _toDouble(json['quantity']),
      unitPrice: _toDouble(json['unit_price']),
      totalPrice: _toDouble(json['total_price']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}

class InventoryTransaction {
  final String id;
  final String transactionNumber;
  final String transactionType;

  final String? customerId;
  final String? supplierId;

  final double totalAmount;
  final String status;
  final String? notes;

  final List<TransactionItem> items;

  InventoryTransaction({
    required this.id,
    required this.transactionNumber,
    required this.transactionType,
    this.customerId,
    this.supplierId,
    required this.totalAmount,
    required this.status,
    this.notes,
    required this.items,
  });

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) {
    return InventoryTransaction(
      id: json['id']?.toString() ?? '',
      transactionNumber: json['transaction_number']?.toString() ?? '',
      transactionType: json['transaction_type']?.toString() ?? '',
      customerId: json['customer_id']?.toString(),
      supplierId: json['supplier_id']?.toString(),
      totalAmount: _toDouble(json['total_amount']),
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString(),
      items: (json['items'] as List? ?? [])
          .map((item) => TransactionItem.fromJson(item))
          .toList(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}
