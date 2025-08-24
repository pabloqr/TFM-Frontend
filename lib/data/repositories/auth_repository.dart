import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/features/auth/data/models/auth_model.dart';
import 'package:frontend/features/auth/data/models/sign_in_request_model.dart';
import 'package:frontend/features/auth/data/models/sign_up_request_model.dart';
import 'package:frontend/features/auth/data/models/tokens_model.dart';
import 'package:frontend/features/auth/data/services/auth_local_service.dart';
import 'package:frontend/features/auth/data/services/auth_remote_service.dart';
import 'package:frontend/features/users/data/models/user_model.dart';

abstract class AuthRepository {
  /// Sign up a new user
  ///
  /// Throws a [ServerException], [NetworkException], [CacheException], or [UnexpectedFailure] if an error occurs.
  Future<Either<Failure, AuthModel>> signUp({required SignUpRequestModel request});

  /// Sign in a user
  ///
  /// Throws a [ServerException], [NetworkException], [CacheException], or [UnexpectedFailure] if an error occurs.
  Future<Either<Failure, AuthModel>> signIn({required SignInRequestModel request});

  /// Auto sign in a user
  ///
  /// Throws a [ServerException], [NetworkException], [CacheException], or [UnexpectedFailure] if an error occurs.
  Future<Either<Failure, bool>> autoSignIn();

  /// Refresh the access token
  ///
  /// Throws a [ServerException], [NetworkException], [CacheException], or [UnexpectedFailure] if an error occurs.
  Future<Either<Failure, TokensModel>> refreshToken();

  /// Get a valid access token
  ///
  /// Throws a [CacheException] if no access token is found.
  Future<Either<Failure, String>> getValidAccessToken();

  /// Sign out the current user
  ///
  /// Throws a [ServerException], [NetworkException], [CacheException], or [UnexpectedFailure] if an error occurs.
  Future<Either<Failure, void>> signOut();

  //------------------------------------------------------------------------------------------------------------------//
  //------------------------------------------------------------------------------------------------------------------//

  /// Check if the user is authenticated
  ///
  /// Throws a [CacheException] if an error occurs during the check.
  Future<Either<Failure, bool>> isUserAuthenticated();

  /// Get the authenticated user
  ///
  /// Throws a [CacheException] if an error occurs during the check.
  Future<Either<Failure, UserModel>> getAuthenticatedUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteService _remoteService;
  final AuthLocalService _localService;

  AuthRepositoryImpl({required AuthRemoteService remoteService, required AuthLocalService localService})
    : _remoteService = remoteService,
      _localService = localService;

  @override
  Future<Either<Failure, AuthModel>> signUp({required SignUpRequestModel request}) async {
    try {
      // Intenta realizar el registro a través del servicio remoto.
      final response = await _remoteService.signUp(request);

      // Si el registro remoto es exitoso, guarda los tokens y la información del usuario localmente.
      try {
        await Future.wait([
          _localService.saveTokens(
            TokensModel(
              accessToken: response.accessToken,
              refreshToken: response.refreshToken,
              expiresIn: response.expiresIn,
            ),
          ),
          _localService.saveUser(response.user),
        ]);
      } catch (e) {
        // Si falla el guardado local, devuelve un error de caché.
        return Left(CacheFailure(message: 'Failed to save data after sign up: ${e.toString()}'));
      }

      // Devuelve la respuesta exitosa del registro.
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error during sign up: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthModel>> signIn({required SignInRequestModel request}) async {
    try {
      // Intenta iniciar sesión a través del servicio remoto.
      final response = await _remoteService.signIn(request);

      // Si el inicio de sesión remoto es exitoso, guarda los tokens y la información del usuario localmente.
      try {
        await Future.wait([
          _localService.saveTokens(
            TokensModel(
              accessToken: response.accessToken,
              refreshToken: response.refreshToken,
              expiresIn: response.expiresIn,
            ),
          ),
          _localService.saveUser(response.user),
        ]);
      } catch (e) {
        // Si falla el guardado local, devuelve un error de caché.
        return Left(CacheFailure(message: 'Failed to save data after sign in: ${e.toString()}'));
      }

      // Devuelve la respuesta exitosa del inicio de sesión.
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error during sign in: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> autoSignIn() async {
    try {
      // Primero, verifica si el usuario ya está autenticado localmente.
      final isAuthenticatedResult = await isUserAuthenticated();
      return isAuthenticatedResult.fold(
        (failure) => Left(failure), // Si hay un error al verificar, propaga el error.
        (isAuthenticated) async {
          // Si está autenticado, procede a obtener los datos del usuario.
          final getUserResult = await getAuthenticatedUser();
          return getUserResult.fold(
            (failure) => Left(failure), // Si hay un error al obtener el usuario, propaga el error.
            (user) async {
              // Si se obtiene el usuario, intenta obtener un token de acceso válido.
              final getValidAccessTokenResult = await getValidAccessToken();
              return getValidAccessTokenResult.fold(
                (failure) => Left(failure), // Si hay un error al obtener el token, propaga el error.
                (accessToken) async {
                  // Si todas las comprobaciones son exitosas, el auto-login es satisfactorio.
                  return Right(true);
                },
              );
            },
          );
        },
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error during auto sign in: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, TokensModel>> refreshToken() async {
    try {
      // Obtiene el token de refresco del almacenamiento local.
      final refreshToken = await _localService.getRefreshToken();
      if (refreshToken == null) {
        // Si no hay token de refresco, el usuario necesita iniciar sesión de nuevo.
        return Left(CacheFailure(message: 'No refresh token found. Please sign in before refreshing your tokens.'));
      }

      // Solicita nuevos tokens al servidor utilizando el token de refresco.
      final response = await _remoteService.refreshToken(refreshToken);

      // Guarda los nuevos tokens localmente.
      _localService.saveTokens(
        TokensModel(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          expiresIn: response.expiresIn,
        ),
      );

      // Devuelve los nuevos tokens.
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error during refresh token: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> getValidAccessToken() async {
    try {
      // Verifica si el token de acceso actual ha expirado.
      final isExpired = await _localService.isTokenExpired();
      if (isExpired) {
        // Si ha expirado, intenta refrescar los tokens.
        // El resultado de refreshToken() es un Either, por lo que usamos fold para manejar éxito o fracaso.
        return (await refreshToken()).fold(
          (failure) => Left(failure), // Si el refresco falla, propaga el error.
          (tokensModel) =>
              Right(tokensModel.accessToken), // Si el refresco es exitoso, devuelve el nuevo token de acceso.
        );
      }

      // Si el token no ha expirado, obtén el token de acceso actual del almacenamiento local.
      final accessToken = await _localService.getAccessToken();
      return accessToken == null
          ? Left(CacheFailure(message: 'No access token found.')) // Si no se encuentra, devuelve error de caché.
          : Right(accessToken); // Si se encuentra, devuélvelo.
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error during authentication check: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // Obtiene el token de acceso actual.
      final accessToken = await _localService.getAccessToken();
      if (accessToken != null) {
        // Si existe un token, intenta invalidarlo en el servidor.
        // No se maneja el error de _remoteService.signOut explícitamente aquí para asegurar la limpieza local.
        await _remoteService.signOut(accessToken);
      }
      // Devuelve éxito independientemente del resultado del cierre de sesión remoto,
      // ya que el objetivo principal es limpiar los datos locales.
      return Right(null);
    } on ServerException catch (e) {
      // Captura errores específicos del servidor si ocurren durante el signOut remoto.
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      // Captura errores de red si ocurren.
      return Left(NetworkFailure(message: e.message));
    } on CacheException catch (e) {
      // Captura errores de caché si ocurren al obtener el token.
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      // Captura cualquier otro error inesperado.
      return Left(UnexpectedFailure(message: 'Unexpected error during sign out: ${e.toString()}'));
    } finally {
      // Asegura que los tokens y la información del usuario se eliminen localmente,
      // independientemente de si el cierre de sesión remoto fue exitoso o no.
      await Future.wait([_localService.deleteAllTokens(), _localService.deleteUser()]);
    }
  }

  //------------------------------------------------------------------------------------------------------------------//
  //------------------------------------------------------------------------------------------------------------------//

  @override
  Future<Either<Failure, bool>> isUserAuthenticated() async {
    try {
      // Comprueba si existen tokens válidos y si hay información de usuario guardada localmente.
      final hasValidTokens = await _localService.hasValidTokens();
      final hasValidUser = await _localService.getUser() != null;
      // El usuario está autenticado si ambas condiciones son verdaderas.
      return Right(hasValidTokens && hasValidUser);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error during authentication check: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getAuthenticatedUser() async {
    try {
      // Primero, verifica si el usuario está considerado como autenticado.
      final isUserAuthenticatedResult = await isUserAuthenticated();
      return isUserAuthenticatedResult.fold(
        (failure) => Left(failure), // Si la comprobación de autenticación falla, propaga el error.
        (isAuthenticated) async {
          // Si está autenticado, intenta obtener los datos del usuario del almacenamiento local.
          final user = await _localService.getUser();
          return user != null
              ? Right(user) // Si se encuentra el usuario, devuélvelo.
              : Left(CacheFailure(message: 'No user found.')); // Si no se encuentra, devuelve un error de caché.
        },
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error during authentication check: ${e.toString()}'));
    }
  }
}
