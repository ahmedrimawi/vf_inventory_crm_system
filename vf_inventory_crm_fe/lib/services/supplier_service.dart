import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/supplier.dart';

class SupplierService {
  final DioClient _client = DioClient();

  Future<List<Supplier>> getSuppliers({String search = ''}) async {
    final response = await _client.dio.get(
      ApiConstants.suppliers,
      queryParameters: {if (search.isNotEmpty) 'search': search},
    );

    return (response.data as List)
        .map((item) => Supplier.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Supplier> createSupplier({
    required String name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
  }) async {
    final response = await _client.dio.post(
      '/suppliers',
      data: {
        'name': name,
        'contact_person': contactPerson,
        'phone': phone,
        'email': email,
        'address': address,
      },
    );

    return Supplier.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<void> deleteSupplier(String id) async {
    await _client.dio.delete('/suppliers/$id');
  }
}
