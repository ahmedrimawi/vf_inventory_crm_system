import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/customer.dart';

class CustomerService {
  final DioClient _client = DioClient();

  Future<List<Customer>> getCustomers({String search = ''}) async {
    final response = await _client.dio.get(
      ApiConstants.customers,
      queryParameters: {if (search.isNotEmpty) 'search': search},
    );

    return (response.data as List)
        .map((item) => Customer.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Customer> createCustomer({
    required String name,
    String? phone,
    String? email,
    String? address,
  }) async {
    final response = await _client.dio.post(
      '/customers',
      data: {'name': name, 'phone': phone, 'email': email, 'address': address},
    );

    return Customer.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<void> deleteCustomer(String id) async {
    await _client.dio.delete('/customers/$id');
  }
}
