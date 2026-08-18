import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';
import '../models/user.dart';

class AuthService {
  final DioClient client;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  AuthService(this.client);

  Future<User> login(String username, String password) async {
    final response = await client.dio.post(
      ApiConstants.login,
      data: {'username': username, 'password': password},
    );

    print('LOGIN STATUS: ${response.statusCode}');
    print('LOGIN RESPONSE: ${response.data}');

    final data = response.data as Map<String, dynamic>;

    print('ACCESS TOKEN EXISTS: ${data['access_token'] != null}');
    print('USER ID: ${data['user_id']}');
    print('USERNAME: ${data['username']}');
    print('IS ACTIVE: ${data['is_active']}');

    await storage.write(key: 'access_token', value: data['access_token']);

    await storage.write(key: 'user_id', value: data['user_id']);

    return User.fromJson(data);
  }

  Future<void> logout() async {
    await storage.delete(key: 'access_token');

    await storage.delete(key: 'user_id');
  }
}
