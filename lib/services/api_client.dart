import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';

// ─────────────────────────────────────────────────────────────
// ApiClient — singleton Dio dengan:
//  - baseUrl dari AppConstants
//  - Authorization header otomatis dari token di storage
//  - Interceptor log error & handle 401 (token expired)
// ─────────────────────────────────────────────────────────────
class ApiClient {
  ApiClient._();
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;

  final _storage = const FlutterSecureStorage();

  Dio get dio => _dio;
  late final Dio _dio = _buildDio();

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        // ── Request: sisipkan token ──────────────────────────
        onRequest: (options, handler) async {
          final token = await _storage.read(key: AppConstants.keyToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        // ── Response: pass-through ───────────────────────────
        onResponse: (response, handler) => handler.next(response),

        // ── Error: terjemahkan ke Exception yang ramah ───────
        onError: (DioException e, handler) {
          final msg = _parseError(e);
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: msg,
              message: msg,
              type: e.type,
              response: e.response,
            ),
          );
        },
      ),
    );

    return dio;
  }

  String _parseError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi timeout. Periksa jaringan Anda.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
    }
    final data = e.response?.data;
    if (data is Map) {
      // Laravel validation error
      if (data['errors'] != null) {
        final errors = data['errors'] as Map;
        final first = errors.values.first;
        return (first is List ? first.first : first).toString();
      }
      if (data['message'] != null) return data['message'].toString();
    }
    switch (e.response?.statusCode) {
      case 401: return 'Sesi habis. Silakan login kembali.';
      case 403: return 'Anda tidak memiliki akses ke halaman ini.';
      case 404: return 'Data tidak ditemukan.';
      case 422: return 'Data yang dikirim tidak valid.';
      case 500: return 'Terjadi kesalahan pada server.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }
}
