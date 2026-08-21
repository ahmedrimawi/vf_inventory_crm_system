class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double stockQuantity;
  final double minimumStockLevel;
  final double purchasePrice;
  final double sellingPrice;
  final String unit;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.stockQuantity,
    required this.minimumStockLevel,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.unit,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      stockQuantity: _toDouble(json['stock_quantity']),
      minimumStockLevel: _toDouble(json['minimum_stock_level']),
      purchasePrice: _toDouble(json['purchase_price']),
      sellingPrice: _toDouble(json['selling_price']),
      unit: json['unit']?.toString() ?? 'piece',
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }
}
