import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/features/auth/data/models/tokens_model.dart';
import 'package:frontend/features/users/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key to store the access token in FlutterSecureStorage.
const String _accessTokenKey = 'access_token';

/// Key to store the refresh token in FlutterSecureStorage.
const String _refreshTokenKey = 'refresh_token';

/// Key to store the token expiration time in FlutterSecureStorage.
const String _expiresInKey = 'expires_in';

/// Key to store the cached [UserModel] in SharedPreferences.
const String _userKey = 'user_cache';

/// Interface for the local authentication service.
/// Defines operations to manage authentication tokens and
/// user information in secure local storage and cache.
abstract class AuthLocalService {
  /// Saves authentication tokens in secure storage.
  ///
  /// Throws [CacheException] if an error occurs during saving.
  Future<void> saveTokens(TokensModel tokens);

  /// Saves the [UserModel] in the local cache (SharedPreferences).
  ///
  /// Serializes the [UserModel] to JSON before saving.
  /// Throws [CacheException] if an error occurs during saving.
  Future<void> saveUser(UserModel user);

  /// Gets the access token from secure storage.
  ///
  /// Throws [CacheException] if the token is not found or if an error occurs while reading it.
  Future<String?> getAccessToken();

  /// Gets the refresh token from secure storage.
  ///
  /// Throws [CacheException] if the token is not found or if an error occurs while reading it.
  Future<String?> getRefreshToken();

  /// Gets the [UserModel] from the local cache (SharedPreferences).
  ///
  /// Deserializes JSON to [UserModel].
  /// Throws [CacheException] if the user is not found in cache or if an error occurs while reading it.
  Future<UserModel?> getUser();

  /// Checks if there are valid tokens in secure storage.
  ///
  /// Returns `true` if there are valid tokens, `false` otherwise.
  /// Throws [CacheException] if an error occurs during the check.
  Future<bool> hasValidTokens();

  /// Checks if the access token has expired.
  ///
  /// Returns `true` if the token has expired, `false` otherwise.
  /// Throws [CacheException] if an error occurs during the check.
  Future<bool> isTokenExpired();

  /// Deletes all tokens (access and refresh) and cached user information.
  ///
  /// Throws [CacheException] if an error occurs during the deletion of any data.
  Future<void> deleteAllTokens();

  /// Deletes the [UserModel] from the local cache (SharedPreferences).
  ///
  /// Throws [CacheException] if an error occurs during deletion.
  Future<void> deleteUser();
}

/// Implementation of [AuthLocalService] that uses [FlutterSecureStorage]
/// for tokens and [SharedPreferences] for user information.
class AuthLocalServiceImpl implements AuthLocalService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;

  /// Creates an instance of [AuthLocalServiceImpl].
  ///
  /// Requires an instance of [FlutterSecureStorage] for secure token management
  /// and an instance of [SharedPreferences] for caching user data.
  AuthLocalServiceImpl({required FlutterSecureStorage secureStorage, required SharedPreferences sharedPreferences})
    : _secureStorage = secureStorage,
      _sharedPreferences = sharedPreferences;

  @override
  Future<void> saveTokens(TokensModel tokens) async {
    try {
      final expirationTime = DateTime.now().add(Duration(seconds: tokens.expiresIn));

      Future.wait([
        _secureStorage.write(key: _accessTokenKey, value: tokens.accessToken),
        _secureStorage.write(key: _refreshTokenKey, value: tokens.refreshToken),
        _secureStorage.write(key: _expiresInKey, value: expirationTime.toIso8601String()),
      ]);
    } catch (e) {
      throw CacheException(message: 'Error saving tokens: ${e.toString()}');
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
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: _accessTokenKey);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Error reading access token: ${e.toString()}');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Error reading refresh token: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final String? userJson = _sharedPreferences.getString(_userKey);
      return userJson != null ? UserModel.fromJsonString(userJson) : null;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Error reading user from cache: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasValidTokens() async {
    final tokens = await Future.wait([getAccessToken(), getRefreshToken()]);
    return tokens[0] != null && tokens[1] != null;
  }

  @override
  Future<bool> isTokenExpired() async {
    try {
      final expirationTimeString = await _secureStorage.read(key: _expiresInKey);
      if (expirationTimeString == null) return true;

      final expirationTime = DateTime.parse(expirationTimeString);
      return DateTime.now().isAfter(expirationTime.subtract(Duration(minutes: 1)));
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Error reading expiration time: ${e.toString()}');
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
      await Future.wait([
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _secureStorage.delete(key: _expiresInKey),
      ]);
    } catch (e) {
      // Si alguna de las operaciones de eliminación falla, se propaga la excepción.
      // Podría ser una CacheException de cualquiera de los métodos anteriores.
      throw CacheException(message: 'Error deleting all tokens and user data, some data may persist: ${e.toString()}');
    }
  }
}
