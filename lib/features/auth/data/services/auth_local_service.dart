import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/features/users/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clave para almacenar el token de acceso en FlutterSecureStorage.
const String _accessTokenKey = 'access_token';

/// Clave para almacenar el token de refresco en FlutterSecureStorage.
const String _refreshTokenKey = 'refresh_token';

/// Clave para almacenar el [UserModel] cacheado en SharedPreferences.
const String _userKey = 'user_cache';

/// Interfaz para el servicio de autenticación local.
/// Define las operaciones para gestionar tokens de autenticación y
/// la información del usuario en el almacenamiento local seguro y en la caché.
abstract class AuthLocalService {
  /// Guarda el token de acceso en el almacenamiento seguro.
  ///
  /// Lanza [CacheException] si ocurre un error durante el guardado.
  Future<void> saveAccessToken(String token);

  /// Guarda el token de refresco en el almacenamiento seguro.
  ///
  /// Lanza [CacheException] si ocurre un error durante el guardado.
  Future<void> saveRefreshToken(String token);

  /// Guarda el [UserModel] en la caché local (SharedPreferences).
  ///
  /// Serializa el [UserModel] a JSON antes de guardarlo.
  /// Lanza [CacheException] si ocurre un error durante el guardado.
  Future<void> saveUser(UserModel user);

  /// Obtiene el token de acceso desde el almacenamiento seguro.
  ///
  /// Lanza [CacheException] si el token no se encuentra o si ocurre un error al leerlo.
  Future<String> getAccessToken();

  /// Obtiene el token de refresco desde el almacenamiento seguro.
  ///
  /// Lanza [CacheException] si el token no se encuentra o si ocurre un error al leerlo.
  Future<String> getRefreshToken();

  /// Obtiene el [UserModel] desde la caché local (SharedPreferences).
  ///
  /// Deserializa el JSON a [UserModel].
  /// Lanza [CacheException] si el usuario no se encuentra en caché o si ocurre un error al leerlo.
  Future<UserModel> getUser();

  /// Elimina el token de acceso del almacenamiento seguro.
  ///
  /// Lanza [CacheException] si ocurre un error durante la eliminación.
  Future<void> deleteAccessToken();

  /// Elimina el token de refresco del almacenamiento seguro.
  ///
  /// Lanza [CacheException] si ocurre un error durante la eliminación.
  Future<void> deleteRefreshToken();

  /// Elimina todos los tokens (acceso y refresco) y la información del usuario cacheada.
  ///
  /// Lanza [CacheException] si ocurre un error durante la eliminación de alguno de los datos.
  Future<void> deleteAllTokens();

  /// Elimina el [UserModel] de la caché local (SharedPreferences).
  ///
  /// Lanza [CacheException] si ocurre un error durante la eliminación.
  Future<void> deleteUser();
}

/// Implementación de [AuthLocalService] que utiliza [FlutterSecureStorage]
/// para los tokens y [SharedPreferences] para la información del usuario.
class AuthLocalServiceImpl implements AuthLocalService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;

  /// Crea una instancia de [AuthLocalServiceImpl].
  ///
  /// Requiere una instancia de [FlutterSecureStorage] para el manejo seguro de tokens
  /// y una instancia de [SharedPreferences] para el cacheo de datos del usuario.
  AuthLocalServiceImpl({required FlutterSecureStorage secureStorage, required SharedPreferences sharedPreferences})
    : _secureStorage = secureStorage,
      _sharedPreferences = sharedPreferences;

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      await _secureStorage.write(key: _accessTokenKey, value: token);
    } catch (e) {
      throw CacheException(message: 'Error saving access token: ${e.toString()}');
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      await _secureStorage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      throw CacheException(message: 'Error saving refresh token: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await _sharedPreferences.setString(_userKey, user.toJsonString());
    } catch (e) {
      throw CacheException(message: 'Error saving user to cache: ${e.toString()}');
    }
  }

  @override
  Future<String> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: _accessTokenKey);
      if (token != null) {
        return token;
      } else {
        throw CacheException(message: 'Access token not found');
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Error reading access token: ${e.toString()}');
    }
  }

  @override
  Future<String> getRefreshToken() async {
    try {
      final token = await _secureStorage.read(key: _refreshTokenKey);
      if (token != null) {
        return token;
      } else {
        throw CacheException(message: 'Refresh token not found');
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Error reading refresh token: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getUser() async {
    try {
      final String? userJson = _sharedPreferences.getString(_userKey);
      if (userJson != null) {
        return UserModel.fromJsonString(userJson);
      } else {
        throw CacheException(message: 'User not found in cache');
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Error reading user from cache: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccessToken() async {
    try {
      await _secureStorage.delete(key: _accessTokenKey);
    } catch (e) {
      throw CacheException(message: 'Error deleting access token: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteRefreshToken() async {
    try {
      await _secureStorage.delete(key: _refreshTokenKey);
    } catch (e) {
      throw CacheException(message: 'Error deleting refresh token: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      await _sharedPreferences.remove(_userKey);
      // remove() devuelve true si la entrada existía y fue eliminada, false si no existía.
      // No se considera un error si la clave no existía, por lo que no se lanza CacheException aquí.
    } catch (e) {
      throw CacheException(message: 'Error deleting user from cache: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAllTokens() async {
    try {
      await deleteAccessToken();
      await deleteRefreshToken();
      await deleteUser();
    } catch (e) {
      // Si alguna de las operaciones de eliminación falla, se propaga la excepción.
      // Podría ser una CacheException de cualquiera de los métodos anteriores.
      throw CacheException(message: 'Error deleting all tokens and user data, some data may persist: ${e.toString()}');
    }
  }
}
