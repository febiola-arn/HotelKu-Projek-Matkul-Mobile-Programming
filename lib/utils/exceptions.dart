import 'dart:async';

/// Custom exception for API-related errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? endpoint;

  ApiException(
    this.message, {
    this.statusCode,
    this.endpoint,
  });

  @override
  String toString() => message;

  /// Factory method to create ApiException from HTTP response
  factory ApiException.fromResponse(int statusCode, String endpoint) {
    String message;
    switch (statusCode) {
      case 400:
        message = 'Permintaan tidak valid';
        break;
      case 401:
        message = 'Anda tidak memiliki akses. Silakan login kembali';
        break;
      case 403:
        message = 'Akses ditolak';
        break;
      case 404:
        message = 'Data tidak ditemukan';
        break;
      case 500:
      case 502:
      case 503:
        message = 'Server sedang bermasalah. Coba lagi nanti';
        break;
      default:
        message = 'Terjadi kesalahan. Kode: $statusCode';
    }

    return ApiException(
      message,
      statusCode: statusCode,
      endpoint: endpoint,
    );
  }

  /// Factory method to create ApiException from common errors
  factory ApiException.fromError(dynamic error) {
    if (error is TimeoutException) {
      return ApiException('Koneksi timeout. Periksa internet Anda');
    } else if (error is FormatException) {
      return ApiException('Format data tidak valid');
    } else {
      return ApiException('Terjadi kesalahan: ${error.toString()}');
    }
  }
}

/// Exception for authentication-related errors
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

/// Exception for validation errors
class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  ValidationException(this.message, {this.fieldErrors});

  @override
  String toString() => message;
}

/// Exception for booking-related errors
class BookingException implements Exception {
  final String message;

  BookingException(this.message);

  @override
  String toString() => message;
}
