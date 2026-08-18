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
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      stockQuantity: parseDouble(json['stock_quantity']),
      unit: json['unit']?.toString() ?? 'kg',
      minimumStockLevel: parseDouble(json['minimum_stock_level']),
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
    final lowStockJson = json['low_stock'];

    return DashboardSummary(
      totalProducts: parseInt(json['total_products']),

      totalStock: parseDouble(json['total_stock']),

      totalCustomers: parseInt(json['total_customers']),

      totalSuppliers: parseInt(json['total_suppliers']),

      lowStock: lowStockJson is List
          ? lowStockJson
                .map(
                  (item) =>
                      LowStockProduct.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : [],
    );
  }
}

double parseDouble(dynamic value) {
  if (value == null) {
    return 0.0;
  }

  if (value is double) {
    return value;
  }

  if (value is int) {
    return value.toDouble();
  }

  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value.trim()) ?? 0.0;
  }

  return 0.0;
}

int parseInt(dynamic value) {
  if (value == null) {
    return 0;
  }

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value.trim()) ??
        double.tryParse(value.trim())?.toInt() ??
        0;
  }

  return 0;
}
