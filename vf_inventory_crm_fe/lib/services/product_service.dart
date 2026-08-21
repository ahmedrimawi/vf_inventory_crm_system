import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/product.dart';

class ProductService {
  final DioClient _client = DioClient();

  Future<List<Product>> getProducts({
    String search = '',
    String? category,
  }) async {
    final response = await _client.dio.get(
      ApiConstants.products,
      queryParameters: {
        if (search.isNotEmpty) 'search': search,
        if (category != null) 'category': category,
      },
    );

    return (response.data as List)
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Product> createProduct({
    required String name,
    String? sku,
    String? category,
    String? description,
    required String unit,
    required double purchasePrice,
    required double sellingPrice,
    required double stockQuantity,
    required double minimumStockLevel,
    String? supplierId,
  }) async {
    final response = await _client.dio.post(
      '/products',
      data: {
        'name': name,
        'sku': sku,
        'category': category,
        'description': description,
        'unit': unit,
        'purchase_price': purchasePrice,
        'selling_price': sellingPrice,
        'stock_quantity': stockQuantity,
        'minimum_stock_level': minimumStockLevel,
        'supplier_id': supplierId,
      },
    );

    return Product.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<void> deleteProduct(String id) async {
    await _client.dio.delete('/products/$id');
  }
}
