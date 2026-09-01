// lib/core/repositories/auth_repository.dart
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../../features/auth/user_model.dart';

class AuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  static String? _findToken(dynamic data) {
    if (data == null) return null;
    if (data is String) {
      if (data.startsWith('ey') && data.contains('.')) return data;
      return null;
    }
    if (data is Map) {
      final explicitToken = data['sessionToken'] ??
          data['token'] ??
          data['accessToken'] ??
          data['jwt'] ??
          data['data']?['sessionToken'] ??
          data['data']?['token'];
      if (explicitToken is String && explicitToken.isNotEmpty) {
        return explicitToken;
      }
      for (final entry in data.entries) {
        final k = entry.key.toString().toLowerCase();
        final v = entry.value;
        if (k.contains('token') || k.contains('jwt') || k.contains('auth')) {
          if (v is String && v.isNotEmpty) return v;
          if (v is Map) {
            final nested = _findToken(v);
            if (nested != null) return nested;
          }
        } else if (v is String && v.startsWith('ey') && v.contains('.')) {
          return v;
        } else if (v is Map) {
          final nested = _findToken(v);
          if (nested != null) return nested;
        }
      }
    }
    return null;
  }

  /// Register customer account
  Future<dynamic> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? confirmPassword,
  }) async {
    final response = await _client.post('/auth/register', body: {
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword ?? password,
    });

    dev.log('Register Response: $response', name: 'AuthRepository');

    final token = _findToken(response);
    if (token != null && token.isNotEmpty) {
      await _client.setToken(token);
    }

    return response;
  }

  /// Authenticate customer
  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final response = await _client.post('/auth/login', body: {
      'emailOrPhone': emailOrPhone,
      'password': password,
    });

    dev.log('Login Response: $response', name: 'AuthRepository');

    final token = _findToken(response);
    if (token == null || token.isEmpty) {
      final msg = (response is Map && response['message'] != null)
          ? response['message'].toString()
          : (response is Map && response['error'] != null)
              ? response['error'].toString()
              : 'Login failed: No authorization token received from server.';
      throw ApiException(msg, body: response);
    }

    await _client.setToken(token);

    final userData = (response is Map && response['user'] != null)
        ? response['user']
        : (response is Map && response['data']?['user'] != null)
            ? response['data']['user']
            : (response is Map && response['data'] != null && response['data'] is Map)
                ? response['data']
                : response;

    if (userData is Map<String, dynamic>) {
      return UserModel.fromJson(userData);
    }

    return UserModel(
      id: 'usr-1',
      name: emailOrPhone.split('@').first,
      email: emailOrPhone,
      phone: emailOrPhone,
    );
  }

  /// Verify email address with code/token
  Future<dynamic> verifyEmail({required String email, required String code}) async {
    return await _client.post('/auth/verify-email', body: {
      'email': email,
      'token': code,
    });
  }

  /// Request password reset token
  Future<dynamic> sendResetToken({required String emailOrPhone}) async {
    return await _client.post('/auth/send-token', body: {
      'email': emailOrPhone,
      'phone': emailOrPhone,
    });
  }

  /// Reset customer password with reset token
  Future<dynamic> resetPassword({
    required String token,
    required String newPassword,
    String? confirmPassword,
  }) async {
    return await _client.patch('/auth/reset-password', body: {
      'resetToken': token,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword ?? newPassword,
    });
  }

  /// Reactivate account
  Future<dynamic> reactivate({required String emailOrPhone, required String password}) async {
    return await _client.post('/auth/reactivate', body: {
      'emailOrPhone': emailOrPhone,
      'password': password,
    });
  }

  /// Retrieve current profile
  Future<UserModel?> getMe() async {
    try {
      final response = await _client.get('/auth/me');
      final userData = (response is Map && response['user'] != null)
          ? response['user']
          : (response is Map && response['data']?['user'] != null)
              ? response['data']['user']
              : response;
      if (userData is Map<String, dynamic>) {
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Update profile details (multipart name, phone, address, image)
  Future<dynamic> updateProfile({
    String? name,
    String? phone,
    String? address,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    final fields = <String, String>{};
    if (name != null && name.isNotEmpty) fields['name'] = name;
    if (phone != null && phone.isNotEmpty) fields['phone'] = phone;
    if (address != null && address.isNotEmpty) fields['address'] = address;

    final files = <http.MultipartFile>[];
    if (imageBytes != null && imageName != null) {
      files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageName,
      ));
    }

    return await _client.patchMultipart('/auth/me', fields: fields, files: files);
  }

  /// Change password
  Future<dynamic> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _client.patch('/auth/change-password', body: {
      'oldPassword': currentPassword,
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

  /// Delete account permanently
  Future<dynamic> deleteAccount() async {
    final response = await _client.post('/auth/delete');
    await _client.clearToken();
    return response;
  }

  /// Diagnostic check for current JWT status
  Future<dynamic> getCurrentJwt() async {
    return await _client.get('/test/jwt/current');
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

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final loggedIn = await ref.watch(isLoggedInStateProvider.future);
  if (!loggedIn) return null;
  return ref.read(authRepositoryProvider).getMe();
});

