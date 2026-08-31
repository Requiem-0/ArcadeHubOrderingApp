// lib/core/network/api_client.dart
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic body;

  ApiException(this.message, {this.statusCode, this.body});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  static String get _defaultBaseUrl => AppConstants.apiBaseUrl;
  static const String _tokenKey = 'auth_token';

  final String baseUrl;
  final http.Client _client;

  ApiClient({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? _defaultBaseUrl,
        _client = client ?? http.Client();

  /// Read token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Save token to SharedPreferences
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Clear token on logout
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Headers builder with optional bearer auth
  Future<Map<String, String>> _headers({Map<String, String>? extraHeaders}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullUrl = '$baseUrl$cleanEndpoint';

    if (queryParameters == null || queryParameters.isEmpty) {
      return Uri.parse(fullUrl);
    }

    final queryMap = queryParameters.map((k, v) => MapEntry(k, v.toString()));
    return Uri.parse(fullUrl).replace(queryParameters: queryMap);
  }

  // ── HTTP VERBS ──────────────────────────────────────────────

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = await _headers();
      dev.log('GET -> $uri', name: 'ApiClient');

      final response = await _client.get(uri, headers: headers);
      return _processResponse(response);
    } catch (e) {
      dev.log('GET Error: $e', name: 'ApiClient', error: e);
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, {dynamic body, Map<String, dynamic>? queryParams}) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = await _headers();
      final bodyString = body != null ? jsonEncode(body) : null;
      dev.log('POST -> $uri | Body: $bodyString', name: 'ApiClient');

      final response = await _client.post(uri, headers: headers, body: bodyString);
      return _processResponse(response);
    } catch (e) {
      dev.log('POST Error: $e', name: 'ApiClient', error: e);
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, {dynamic body, Map<String, dynamic>? queryParams}) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = await _headers();
      final bodyString = body != null ? jsonEncode(body) : null;
      dev.log('PUT -> $uri', name: 'ApiClient');

      final response = await _client.put(uri, headers: headers, body: bodyString);
      return _processResponse(response);
    } catch (e) {
      dev.log('PUT Error: $e', name: 'ApiClient', error: e);
      rethrow;
    }
  }

  Future<dynamic> patch(String endpoint, {dynamic body, Map<String, dynamic>? queryParams}) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = await _headers();
      final bodyString = body != null ? jsonEncode(body) : null;
      dev.log('PATCH -> $uri', name: 'ApiClient');

      final response = await _client.patch(uri, headers: headers, body: bodyString);
      return _processResponse(response);
    } catch (e) {
      dev.log('PATCH Error: $e', name: 'ApiClient', error: e);
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint, {dynamic body, Map<String, dynamic>? queryParams}) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = await _headers();
      final bodyString = body != null ? jsonEncode(body) : null;
      dev.log('DELETE -> $uri', name: 'ApiClient');

      final response = await _client.delete(uri, headers: headers, body: bodyString);
      return _processResponse(response);
    } catch (e) {
      dev.log('DELETE Error: $e', name: 'ApiClient', error: e);
      rethrow;
    }
  }

  dynamic _processResponse(http.Response response) {
    final status = response.statusCode;
    dynamic bodyJson;

    if (response.body.isNotEmpty) {
      try {
        bodyJson = jsonDecode(response.body);
      } catch (_) {
        bodyJson = response.body;
      }
    }

    if (status >= 200 && status < 300) {
      return bodyJson;
    }

    final message = (bodyJson is Map && bodyJson['message'] != null)
        ? bodyJson['message'].toString()
        : 'HTTP Error $status';

    throw ApiException(message, statusCode: status, body: bodyJson);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

