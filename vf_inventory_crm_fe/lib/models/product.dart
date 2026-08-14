class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double quantity;
  final double minQuantity;
  final double purchasePrice;
  final double sellingPrice;
  final String unit;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.quantity,
    required this.minQuantity,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.unit,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      category: json['category'] ?? '',
      quantity: (json['quantity'] as num).toDouble(),
      minQuantity: (json['min_quantity'] as num).toDouble(),
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      sellingPrice: (json['selling_price'] as num).toDouble(),
      unit: json['unit'] ?? 'kg',
    );
  }
}
