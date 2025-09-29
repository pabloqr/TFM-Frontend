import 'dart:async';
import 'dart:convert';

import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/features/auth/data/models/auth_model.dart';
import 'package:frontend/features/auth/data/models/sign_in_request_model.dart';
import 'package:frontend/features/auth/data/models/sign_up_request_model.dart';
import 'package:frontend/features/auth/data/models/tokens_model.dart';
import 'package:http/http.dart' as http;

/// Abstract class for authentication remote service.
abstract class AuthRemoteService {
  /// Signs up a user.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<AuthModel> signUp(SignUpRequestModel request);

  /// Signs in a user.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<AuthModel> signIn(SignInRequestModel request);

  /// Refreshes an access token.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<TokensModel> refreshToken(String refreshToken);

  /// Signs out a user.
  Future<void> signOut(String accessToken);
}

/// Implementation of [AuthRemoteService].
class AuthRemoteServiceImpl implements AuthRemoteService {
  final http.Client _client;

  AuthRemoteServiceImpl({required http.Client client}) : _client = client;

  /// Signs up a user with the given [request].
  ///
  /// Returns an [AuthModel] if successful.
  /// Throws a [NetworkException] if a network error occurs.
  /// Throws a [ServerException] if the server returns an error.
  /// Throws an [UnexpectedException] if an unexpected error occurs.
  @override
  Future<AuthModel> signUp(SignUpRequestModel request) async {
    final Uri uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.signUpEndpoint}');

    try {
      // Realizar la solicitud POST al backend.
      final response = await _client
          .post(uri, headers: {'Content-Type': 'application/json'}, body: request.toJsonString())
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Connection timeout', const Duration(seconds: 10)),
          );

      final Map<String, dynamic> data;
      try {
        // Decodificar la respuesta JSON.
        data = json.decode(utf8.decode(response.bodyBytes));
      } catch (e) {
        // Manejar errores de decodificación.
        throw UnexpectedException(message: 'Error decoding response body: ${e.toString()}');
      }

      if (response.statusCode == 201) {
        // Si el registro es exitoso (código 201), parsear y devolver los datos de autenticación.
        return AuthModel.fromJson(data);
      } else {
        // Si hay un error en el servidor, lanzar una ServerException.
        throw ServerException(
          message: data['message'] ?? 'Error signing up: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException catch (e) {
      throw NetworkException(message: 'Connection timeout during sign up: ${e.message}');
    } catch (e) {
      // Relanzar ServerException si ya es de ese tipo.
      if (e is ServerException) rethrow;
      // En caso de otros errores (posiblemente de red), lanzar NetworkException.
      throw NetworkException(message: 'Network error signing up: ${e.toString()}');
    }
  }

  /// Signs in a user with the given [request].
  ///
  /// Returns an [AuthModel] if successful.
  /// Throws a [NetworkException] if a network error occurs.
  /// Throws a [ServerException] if the server returns an error.
  /// Throws an [UnexpectedException] if an unexpected error occurs.
  @override
  Future<AuthModel> signIn(SignInRequestModel request) async {
    final Uri uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.signInEndpoint}');

    try {
      // Realizar la solicitud POST al backend.
      final response = await _client
          .post(uri, headers: {'Content-Type': 'application/json'}, body: request.toJsonString())
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Connection timeout', const Duration(seconds: 10)),
          );

      final Map<String, dynamic> data;
      try {
        // Decodificar la respuesta JSON.
        data = json.decode(utf8.decode(response.bodyBytes));
      } catch (e) {
        // Manejar errores de decodificación.
        throw UnexpectedException(message: 'Error decoding response body: ${e.toString()}');
      }

      if (response.statusCode == 200) {
        // Si el inicio de sesión es exitoso (código 200), parsear y devolver los datos de autenticación.
        return AuthModel.fromJson(data);
      } else {
        // Si hay un error en el servidor, lanzar una ServerException.
        throw ServerException(
          message: data['message'] ?? 'Error signing in: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException catch (e) {
      throw NetworkException(message: 'Connection timeout during sign up: ${e.message}');
    } catch (e) {
      // Relanzar ServerException si ya es de ese tipo.
      if (e is ServerException) rethrow;
      // En caso de otros errores (posiblemente de red), lanzar NetworkException.
      throw NetworkException(message: 'Network error signing in: ${e.toString()}');
    }
  }

  /// Refreshes the access token using the provided [refreshToken].
  ///
  /// Returns a [TokensModel] containing the new access and refresh tokens if successful.
  /// Throws a [NetworkException] if a network error occurs.
  /// Throws a [ServerException] if the server returns an error.
  /// Throws an [UnexpectedException] if an unexpected error occurs.
  @override
  Future<TokensModel> refreshToken(String refreshToken) async {
    final Uri uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.refreshTokenEndpoint}');

    try {
      // Realizar la solicitud POST al backend.
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              // Asegurarse que el cuerpo es un string JSON
              'refreshToken': refreshToken,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Connection timeout', const Duration(seconds: 10)),
          );

      final Map<String, dynamic> data;
      try {
        // Decodificar la respuesta JSON.
        data = json.decode(utf8.decode(response.bodyBytes));
      } catch (e) {
        // Manejar errores de decodificación.
        throw UnexpectedException(message: 'Error decoding response body: ${e.toString()}');
      }

      if (response.statusCode == 200) {
        // Si la actualización del token es exitosa (código 200), parsear y devolver los nuevos tokens.
        return TokensModel.fromJson(data);
      } else {
        // Si hay un error en el servidor, lanzar una ServerException.
        throw ServerException(
          message: data['message'] ?? 'Error refreshing token: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException catch (e) {
      throw NetworkException(message: 'Connection timeout during sign up: ${e.message}');
    } catch (e) {
      // Relanzar ServerException si ya es de ese tipo.
      if (e is ServerException) rethrow;
      // En caso de otros errores (posiblemente de red), lanzar NetworkException.
      throw NetworkException(message: 'Network error refreshing token: ${e.toString()}');
    }
  }

  /// Signs out the user with the given [accessToken].
  ///
  /// This method is not yet implemented.
  @override
  Future<void> signOut(String accessToken) async {
    final Uri uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.signOutEndpoint}');

    try {
      final response = await _client
          .post(uri, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Connection timeout', const Duration(seconds: 10)),
          );

      if (response.statusCode == 200) {
        return;
      } else {
        final Map<String, dynamic> data;
        try {
          // Decodificar la respuesta JSON.
          data = json.decode(utf8.decode(response.bodyBytes));
        } catch (e) {
          // Manejar errores de decodificación.
          throw UnexpectedException(message: 'Error decoding response body: ${e.toString()}');
        }

        throw ServerException(
          message: data['message'] ?? 'Error signing out: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException catch (e) {
      throw NetworkException(message: 'Connection timeout during sign up: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(message: 'Network error signing out: ${e.toString()}');
    }
  }
}
