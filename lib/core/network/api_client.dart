import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';
import 'api_interceptor.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _authToken;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(ApiInterceptor());
    loadToken(); // 🔹 Automatically loads token at startup
  }

  /// 🔹 Load saved token from secure storage
  Future<void> loadToken() async {
    try {
      final savedToken = await _secureStorage.read(key: 'auth_token');
      if (savedToken != null && savedToken.isNotEmpty) {
        _authToken = savedToken;
        print('🔑 Loaded token from secure storage');
      }
    } catch (e) {
      print('⚠️ Error loading token from storage: $e');
    }
  }

  /// 🔹 Save token securely
  Future<void> setAuthToken(String token) async {
    try {
      _authToken = token;
      await _secureStorage.write(key: 'auth_token', value: token);
      print('✅ Token securely saved');
    } catch (e) {
      print('⚠️ Failed to save token: $e');
    }
  }

  /// 🔹 Clear token securely (logout)
  Future<void> clearAuthToken() async {
    try {
      _authToken = null;
      await _secureStorage.delete(key: 'auth_token');
      print('🗑️ Token cleared from secure storage');
    } catch (e) {
      print('⚠️ Failed to clear token: $e');
    }
  }

  /// 🔹 Add Authorization header only when token exists
  Options _withAuthHeader([Options? options]) {
    final headers = Map<String, dynamic>.from(options?.headers ?? {});
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return (options ?? Options()).copyWith(headers: headers);
  }

  /// 🔹 GET request
  Future<Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? query,
        Options? options,
      }) {
    return _dio.get(
      path,
      queryParameters: query,
      options: _withAuthHeader(options),
    );
  }

  /// 🔹 POST request
  Future<Response<T>> post<T>(
      String path, {
        dynamic data,
        Options? options,
      }) {
    return _dio.post(
      path,
      data: data,
      options: _withAuthHeader(options),
    );
  }

  /// 🔹 PUT request (optional)
  Future<Response<T>> put<T>(
      String path, {
        dynamic data,
        Options? options,
      }) {
    return _dio.put(
      path,
      data: data,
      options: _withAuthHeader(options),
    );
  }

  /// 🔹 DELETE request (optional)
  Future<Response<T>> delete<T>(
      String path, {
        dynamic data,
        Options? options,
      }) {
    return _dio.delete(
      path,
      data: data,
      options: _withAuthHeader(options),
    );
  }
}
