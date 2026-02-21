/// Base Exception class
class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Server Exception
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

/// Cache Exception
class CacheException extends AppException {
  const CacheException(super.message);
}

/// Network Exception
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Validation Exception
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Authentication Exception
class AuthenticationException extends AppException {
  const AuthenticationException(super.message, {super.statusCode});
}

/// Authorization Exception
class AuthorizationException extends AppException {
  const AuthorizationException(super.message, {super.statusCode});
}

