import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/dio_client.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(dioClientProvider));
});

class AuthNotifier extends Notifier<User?> {
  late final AuthService authService;

  @override
  User? build() {
    authService = ref.read(authServiceProvider);
    return null;
  }

  Future<void> login(String username, String password) async {
    state = await authService.login(username, password);
  }

  Future<void> logout() async {
    await authService.logout();
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, User?>(AuthNotifier.new);
