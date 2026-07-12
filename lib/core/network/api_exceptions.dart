import 'package:dio/dio.dart';

/// Custom exception class to handle all API errors cleanly
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  factory ApiException.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        return ApiException('Request to API server was cancelled');
      case DioExceptionType.connectionTimeout:
        return ApiException('Connection timeout with API server');
      case DioExceptionType.receiveTimeout:
        return ApiException('Receive timeout in connection with API server');
      case DioExceptionType.sendTimeout:
        return ApiException('Send timeout in connection with API server');
      case DioExceptionType.connectionError:
        return ApiException('No Internet connection. Please check your network.');
      case DioExceptionType.badCertificate:
        return ApiException('Invalid certificate. Security error.');
      case DioExceptionType.badResponse:
        return ApiException._handleError(
          dioError.response?.statusCode,
          dioError.response?.data,
        );
      case DioExceptionType.unknown:
        return ApiException('Unexpected error occurred. Please try again.');
    }
  }

  static ApiException _handleError(int? statusCode, dynamic error) {
    // Attempt to extract server-provided error message if available
    String serverMessage = 'Unknown Error';
    if (error is Map && error.containsKey('message')) {
      serverMessage = error['message'];
    }

    switch (statusCode) {
      case 400:
        return ApiException(serverMessage.isNotEmpty ? serverMessage : 'Bad request', statusCode: statusCode);
      case 401:
        return ApiException('Unauthorized. Please login again.', statusCode: statusCode);
      case 403:
        return ApiException('Forbidden access', statusCode: statusCode);
      case 404:
        return ApiException('Resource not found', statusCode: statusCode);
      case 422:
        return ApiException('Validation Error: $serverMessage', statusCode: statusCode);
      case 500:
        return ApiException('Internal server error', statusCode: statusCode);
      case 502:
        return ApiException('Bad gateway', statusCode: statusCode);
      default:
        return ApiException('Oops something went wrong', statusCode: statusCode);
    }
  }
}
