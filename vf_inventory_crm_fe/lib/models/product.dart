class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final String description;
  final double stockQuantity;
  final double minimumStockLevel;
  final double purchasePrice;
  final double sellingPrice;
  final String unit;
  final String? supplierId;
  final bool isActive;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.description,
    required this.stockQuantity,
    required this.minimumStockLevel,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.unit,
    this.supplierId,
    required this.isActive,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',

      stockQuantity: (json['stock_quantity'] as num?)?.toDouble() ?? 0.0,

      minimumStockLevel:
          (json['minimum_stock_level'] as num?)?.toDouble() ?? 0.0,

      purchasePrice: (json['purchase_price'] as num?)?.toDouble() ?? 0.0,

      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0.0,

      unit: json['unit']?.toString() ?? 'kg',

      supplierId: json['supplier_id']?.toString(),

      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'description': description,
      'stock_quantity': stockQuantity,
      'minimum_stock_level': minimumStockLevel,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'unit': unit,
      'supplier_id': supplierId,
      'is_active': isActive,
    };
  }

  bool get isLowStock {
    return stockQuantity <= minimumStockLevel;
  }
}
