class LowStockProduct {
  final String id;
  final String name;
  final double stockQuantity;
  final String unit;
  final double minimumStockLevel;

  LowStockProduct({
    required this.id,
    required this.name,
    required this.stockQuantity,
    required this.unit,
    required this.minimumStockLevel,
  });

  factory LowStockProduct.fromJson(Map<String, dynamic> json) {
    return LowStockProduct(
      id: json['id'],
      name: json['name'],
      stockQuantity: (json['stock_quantity'] as num).toDouble(),
      unit: json['unit'],
      minimumStockLevel: (json['minimum_stock_level'] as num).toDouble(),
    );
  }
}

class DashboardSummary {
  final int totalProducts;
  final double totalStock;
  final int totalCustomers;
  final int totalSuppliers;
  final List<LowStockProduct> lowStock;

  DashboardSummary({
    required this.totalProducts,
    required this.totalStock,
    required this.totalCustomers,
    required this.totalSuppliers,
    required this.lowStock,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalProducts: json['total_products'],
      totalStock: (json['total_stock'] as num).toDouble(),
      totalCustomers: json['total_customers'],
      totalSuppliers: json['total_suppliers'],
      lowStock: (json['low_stock'] as List)
          .map((item) => LowStockProduct.fromJson(item))
          .toList(),
    );
  }
}
