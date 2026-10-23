import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// Error with the API's own message (shown to the customer as-is) and the HTTP status.
class ApiException implements Exception {
  ApiException(this.message, [this.status]);
  final String message;
  final int? status;

  bool get isUnauthorized => status == 401;

  @override
  String toString() => message;
}

/// Thin wrapper around Dio for the Jyotessa API. Sends the customer's token when logged in.
class ApiClient {
  ApiClient._() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = tokenReader?.call();
          if (token != null && token.isNotEmpty) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
      ),
    );
  }

  static final instance = ApiClient._();

  /// Set by the session provider so every request carries the current token.
  String? Function()? tokenReader;

  final _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) => _send(() => _dio.get(path, queryParameters: _clean(query)));
  Future<Map<String, dynamic>> post(String path, [Object? body]) => _send(() => _dio.post(path, data: body ?? {}));
  Future<Map<String, dynamic>> put(String path, [Object? body]) => _send(() => _dio.put(path, data: body ?? {}));
  Future<Map<String, dynamic>> delete(String path, [Object? body]) => _send(() => _dio.delete(path, data: body));

  Map<String, dynamic>? _clean(Map<String, dynamic>? q) => q == null ? null : (Map.of(q)..removeWhere((_, v) => v == null || v == ''));

  Future<Map<String, dynamic>> _send(Future<Response<dynamic>> Function() call) async {
    try {
      final res = await call();
      final data = res.data;
      return data is Map<String, dynamic> ? data : <String, dynamic>{};
    } on DioException catch (e) {
      final data = e.response?.data;
      if (e.response == null) {
        debugPrint('[api] ${e.requestOptions.method} ${e.requestOptions.path} failed: ${e.type} ${e.error}');
        throw ApiException('We couldn’t reach our servers. Please check your connection and try again.');
      }
      final message = data is Map && data['message'] is String ? data['message'] as String : 'Something went wrong. Please try again.';
      throw ApiException(message, e.response?.statusCode);
    }
  }
}

/// Shortcut used by the repositories.
final api = ApiClient.instance;
