/// Custom exceptions for the offline-first system.
///
/// These exceptions provide detailed error information for different
/// failure scenarios in the caching and network layers.
library;

/// Base class for all application exceptions.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exception thrown when no cached data is available.
class CacheMissException extends AppException {
  final String resourceKey;

  const CacheMissException({
    required this.resourceKey,
    String? msg,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: msg ?? 'No cached data available',
          code: 'CACHE_MISS',
        );

  @override
  String toString() => 'CacheMissException: $message for key: $resourceKey';
}

/// Exception thrown when cached data is corrupted or invalid.
class CacheCorruptedException extends AppException {
  final String resourceKey;

  const CacheCorruptedException({
    required this.resourceKey,
    String? msg,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: msg ?? 'Cached data is corrupted',
          code: 'CACHE_CORRUPTED',
        );

  @override
  String toString() =>
      'CacheCorruptedException: $message for key: $resourceKey';
}

/// Exception thrown when API request fails.
class NetworkException extends AppException {
  final int? statusCode;
  final String? endpoint;

  const NetworkException({
    required String msg,
    this.statusCode,
    this.endpoint,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: msg,
          code: 'NETWORK_ERROR',
        );

  @override
  String toString() =>
      'NetworkException: $message (status: $statusCode, endpoint: $endpoint)';
}

/// Exception thrown when API request times out.
class TimeoutException extends NetworkException {
  final Duration timeout;

  const TimeoutException({
    this.timeout = const Duration(seconds: 30),
    String? msg,
    super.endpoint,
    super.originalError,
    super.stackTrace,
  }) : super(
          msg: msg ?? 'Request timed out',
          statusCode: 408,
        );

  @override
  String toString() => 'TimeoutException: $message after $timeout';
}

/// Exception thrown when server returns 4xx error codes.
class ServerException extends NetworkException {
  const ServerException({
    required int super.statusCode,
    required super.msg,
    super.endpoint,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Exception thrown when server returns 5xx error codes.
class ServerUnavailableException extends ServerException {
  const ServerUnavailableException({
    required super.statusCode,
    String? msg,
    super.endpoint,
    super.originalError,
    super.stackTrace,
  }) : super(
          msg: msg ?? 'Server is unavailable',
        );
}

/// Exception thrown when cache write operation fails.
class CacheWriteException extends AppException {
  final String resourceKey;

  const CacheWriteException({
    required this.resourceKey,
    String? msg,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: msg ?? 'Failed to write cache',
          code: 'CACHE_WRITE_ERROR',
        );

  @override
  String toString() =>
      'CacheWriteException: $message for key: $resourceKey';
}

/// Exception thrown when serialization/deserialization fails.
class SerializationException extends AppException {
  const SerializationException({
    required String msg,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: msg,
          code: 'SERIALIZATION_ERROR',
        );
}