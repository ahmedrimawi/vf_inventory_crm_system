import 'package:vf_inventory_crm_fe/core/constants/api_constants.dart';

import '../core/network/dio_client.dart';
import '../models/dashboard_summary.dart';

import 'package:flutter/foundation.dart';

class DashboardService {
  final DioClient _dioClient = DioClient();

  Future<DashboardSummary> getDashboardSummary() async {
    final response = await _dioClient.dio.get(ApiConstants.dashboardSummary);

    debugPrint('DASHBOARD RESPONSE TYPE: ${response.data.runtimeType}');

    debugPrint('DASHBOARD RESPONSE: ${response.data}');

    return DashboardSummary.fromJson(response.data);
  }
}
