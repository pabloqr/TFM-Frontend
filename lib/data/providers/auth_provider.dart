import 'package:flutter/foundation.dart';
import 'package:frontend/domain/usecases/auth_use_cases.dart';
import 'package:frontend/features/auth/data/models/sign_in_request_model.dart';
// import 'package:frontend/features/users/data/models/user_model.dart';

/// Represents the different states of authentication.
enum AuthState {
  /// The initial state before any authentication attempt.
  initial,

  /// The state when an authentication operation is in progress.
  loading,

  /// The state when the user is successfully authenticated.
  authenticated,

  /// The state when the user is not authenticated.
  unauthenticated,
}

/// Provides authentication-related functionalities and manages the [AuthState].
///
/// It uses [AuthUseCases] to interact with the authentication logic.
class AuthProvider extends ChangeNotifier {
  final AuthUseCases _authUseCases;

  /// Creates an [AuthProvider].
  ///
  /// Requires [authUseCases] to handle authentication operations.
  AuthProvider({required AuthUseCases authUseCases}) : _authUseCases = authUseCases;

  AuthState _state = AuthState.initial;

  // UserModel? _user;

  /// The current authentication state.
  AuthState get state => _state;

  // UserModel? get user => _user;

  /// Sets the authentication state and notifies listeners.
  set state(AuthState value) {
    _state = value;
    notifyListeners();
  }

  // set user(UserModel value) {
  //   _user = value;
  //   notifyListeners();
  // }

  /// Returns `true` if the user is currently authenticated.
  bool get isAuthenticated => _state == AuthState.authenticated;

  /// Returns `true` if an authentication operation is currently in progress.
  bool get isLoading => _state == AuthState.loading;

  /// Initializes the authentication state.
  ///
  /// Attempts to automatically sign in the user.
  /// Sets the state to [AuthState.loading] during the operation.
  /// Updates the state to [AuthState.authenticated] on success,
  /// or [AuthState.unauthenticated] on failure.
  Future<void> initialize() async {
    // Establecer el estado a cargando mientras se intenta el inicio de sesión automático.
    state = AuthState.loading;

    final result = await _authUseCases.autoSignIn();
    result.fold(
      // En caso de fallo, establecer el estado a no autenticado.
      (failure) => state = AuthState.unauthenticated,
      // En caso de éxito, establecer el estado a autenticado.
      (value) => state = AuthState.authenticated,
    );
  }

  /// Signs in the user with the provided [request].
  ///
  /// Sets the state to [AuthState.loading] during the operation.
  /// Returns `true` and sets the state to [AuthState.authenticated] on successful sign-in.
  /// Returns `false` and sets the state to [AuthState.unauthenticated] on failure.
  Future<bool> signIn(SignInRequestModel request) async {
    // Establecer el estado a cargando mientras se procesa la solicitud de inicio de sesión.
    state = AuthState.loading;

    final result = await _authUseCases.signIn(request);
    return result.fold(
      (failure) {
        // Si el inicio de sesión falla, actualizar el estado a no autenticado.
        state = AuthState.unauthenticated;
        return false;
      },
      (value) {
        // Si el inicio de sesión es exitoso, actualizar el estado a autenticado.
        state = AuthState.authenticated;
        return true;
      },
    );
  }

  /// Signs out the current user.
  ///
  /// Sets the state to [AuthState.loading] during the operation.
  /// Sets the state to [AuthState.unauthenticated] after signing out.
  Future<void> signOut() async {
    // Establecer el estado a cargando durante el proceso de cierre de sesión.
    state = AuthState.loading;
    await _authUseCases.signOut();
    // Establecer el estado a no autenticado después de cerrar la sesión.
    state = AuthState.unauthenticated;
  }
}
