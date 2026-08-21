import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/transaction.dart';

class TransactionService {
  final DioClient _client = DioClient();

  Future<List<InventoryTransaction>> getTransactions() async {
    final response = await _client.dio.get(ApiConstants.transactions);

    return (response.data as List)
        .map(
          (item) =>
              InventoryTransaction.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<InventoryTransaction> createTransaction({
    required String transactionType,
    String? customerId,
    String? supplierId,
    String? notes,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _client.dio.post(
      '/transactions',
      data: {
        'transaction_type': transactionType,
        'customer_id': customerId,
        'supplier_id': supplierId,
        'notes': notes,
        'items': items,
      },
    );

    return InventoryTransaction.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<InventoryTransaction> getTransaction(String id) async {
    final response = await _client.dio.get('/transactions/$id');

    return InventoryTransaction.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<void> deleteTransaction(String id) async {
    await _client.dio.delete('/transactions/$id');
  }
}
