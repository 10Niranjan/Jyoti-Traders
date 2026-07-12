import 'dart:developer';
import 'package:dio/dio.dart';

/// Interceptor to log API requests and responses in a readable format.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('====================================');
    log('🚀 REQUEST: [${options.method}] ${options.uri}');
    log('Headers: ${options.headers}');
    if (options.data != null) {
      log('Body: ${options.data}');
    }
    log('====================================');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('====================================');
    log('✅ RESPONSE: [${response.statusCode}] ${response.requestOptions.uri}');
    log('Data: ${response.data}');
    log('====================================');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('====================================');
    log('❌ ERROR: [${err.response?.statusCode}] ${err.requestOptions.uri}');
    log('Message: ${err.message}');
    if (err.response?.data != null) {
      log('Error Data: ${err.response?.data}');
    }
    log('====================================');
    super.onError(err, handler);
  }
}
