import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_exceptions.dart';
import 'logging_interceptor.dart';

/// Provider for the API Client
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Core Network Service using Dio.
/// Handles base configuration, intercepts requests/responses, and standardizes errors.
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    // Initialize Dio with base options
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.yourdomain.com/v1', // TODO: Update with real backend URL
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      LoggingInterceptor(),
      // Add AuthInterceptor here later to attach JWT tokens to requests
    ]);
  }

  /// Generic GET request wrapper
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Generic POST request wrapper
  Future<dynamic> post(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post(endpoint, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Generic PUT request wrapper
  Future<dynamic> put(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.put(endpoint, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Generic DELETE request wrapper
  Future<dynamic> delete(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(endpoint, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
