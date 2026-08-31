// lib/core/repositories/auth_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../../features/auth/user_model.dart';

class AuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  /// Register customer account
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await _client.post('/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
      if (phone != null) 'phone': phone,
    });
    if (response is Map && response.containsKey('token')) {
      await _client.setToken(response['token'].toString());
    }
    final userData = (response is Map && response['user'] != null)
        ? response['user']
        : response;
    return UserModel.fromJson(userData as Map<String, dynamic>);
  }

  /// Authenticate customer
  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final response = await _client.post('/auth/login', body: {
      'email': emailOrPhone,
      'password': password,
    });
    if (response is Map && response.containsKey('token')) {
      await _client.setToken(response['token'].toString());
    }
    final userData = (response is Map && response['user'] != null)
        ? response['user']
        : response;
    return UserModel.fromJson(userData as Map<String, dynamic>);
  }

  /// Verify email address with code/token
  Future<dynamic> verifyEmail({required String email, required String code}) async {
    return await _client.post('/auth/verify-email', body: {
      'email': email,
      'code': code,
    });
  }

  /// Request password reset token
  Future<dynamic> sendResetToken({required String emailOrPhone}) async {
    return await _client.post('/auth/send-token', body: {
      'email': emailOrPhone,
    });
  }

  /// Reset customer password with reset token
  Future<dynamic> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return await _client.patch('/auth/reset-password', body: {
      'token': token,
      'newPassword': newPassword,
    });
  }

  /// Reactivate account
  Future<dynamic> reactivate({required String email}) async {
    return await _client.post('/auth/reactivate', body: {'email': email});
  }

  /// Retrieve current profile
  Future<UserModel?> getMe() async {
    try {
      final response = await _client.get('/auth/me');
      final userData = (response is Map && response['user'] != null)
          ? response['user']
          : response;
      return UserModel.fromJson(userData as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Change password
  Future<dynamic> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _client.patch('/auth/change-password', body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  /// Terminate session
  Future<void> logout() async {
    try {
      await _client.post('/auth/logout');
    } catch (_) {}
    await _client.clearToken();
  }

  /// Deactivate account
  Future<dynamic> deactivate() async {
    final response = await _client.post('/auth/deactivate');
    await _client.clearToken();
    return response;
  }
  /// Check if user has stored auth token
  Future<bool> isLoggedIn() async {
    final token = await _client.getToken();
    return token != null && token.isNotEmpty;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthRepository(client);
});

final isLoggedInStateProvider = FutureProvider<bool>((ref) async {
  return ref.read(authRepositoryProvider).isLoggedIn();
});

