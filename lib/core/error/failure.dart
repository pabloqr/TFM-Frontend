import 'package:equatable/equatable.dart';

/// Clase base para los errores de la aplicación.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];

  @override
  String toString() => '$runtimeType(message: $message, statusCode: $statusCode)';
}

/// Representa un fallo que ocurre en el servidor.
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Representa un fallo que ocurre en el almacenamiento local.
class CacheFailure extends Failure {
  const CacheFailure({required super.message}) : super(statusCode: null);
}

/// Representa un fallo que ocurre con la conexión a internet.
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message}) : super(statusCode: null);
}

/// Representa un fallo inesperado.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message = 'An unexpected error occurred'}) : super(statusCode: null);
}
