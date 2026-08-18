import '../core/network/dio_client.dart';
import '../models/dashboard_summary.dart';

class DashboardService {
  final DioClient _dioClient = DioClient();

  Future<DashboardSummary> getDashboardSummary() async {
    final response = await _dioClient.dio.get('/api/dashboard/summary');

    return DashboardSummary.fromJson(response.data);
  }
}
