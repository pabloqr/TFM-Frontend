/// Representar una excepción que ocurre en el servidor.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({this.message = 'An error occurred on the server', this.statusCode});

  @override
  String toString() => 'ServerException(message: $message, statusCode: $statusCode)';
}

/// Representa una excepción que ocurre cuando ocurre un error en el almacenamiento local.
class CacheException implements Exception {
  final String message;

  CacheException({this.message = 'An error occurred with local cache'});

  @override
  String toString() => 'CacheException(message: $message)';
}

/// Representa una excepción que ocurre cuando no hay conexión a internet.
class NetworkException implements Exception {
  final String message;

  NetworkException({this.message = 'No internet connection'});

  @override
  String toString() => 'NetworkException(message: $message)';
}

class UnexpectedException implements Exception {
  final String message;

  UnexpectedException({this.message = 'An unexpected error occurred'});

  @override
  String toString() => 'UnexpectedException(message: $message)';
}
