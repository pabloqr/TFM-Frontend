import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/features/auth/data/models/auth_model.dart';
import 'package:frontend/features/auth/data/models/sign_in_request_model.dart';
import 'package:frontend/features/auth/data/models/sign_up_request_model.dart';
import 'package:frontend/features/users/data/models/user_model.dart';

class AuthUseCases {
  final AuthRepository _repository;

  /// [AuthUseCases] constructor.
  /// Receives a [AuthRepository] instance.
  AuthUseCases({required AuthRepository repository}) : _repository = repository;

  /// Sign up a new user.
  ///
  /// Returns a [Future] containing a [Either] with a [Failure] or [AuthModel].
  Future<Either<Failure, AuthModel>> signUp(SignUpRequestModel request) async {
    return await _repository.signUp(request: request);
  }

  /// Sign in a user.
  ///
  /// Returns a [Future] containing a [Either] with a [Failure] or [AuthModel].
  Future<Either<Failure, AuthModel>> signIn(SignInRequestModel request) async {
    return await _repository.signIn(request: request);
  }

  /// Auto sign in a user.
  ///
  /// Returns a [Future] containing a [Either] with a [Failure] or [bool].
  Future<Either<Failure, bool>> autoSignIn() async {
    return await _repository.autoSignIn();
  }

  /// Get the authenticated user.
  ///
  /// Returns a [Future] containing a [Either] with a [Failure] or [UserModel].
  Future<Either<Failure, UserModel>> getAuthenticatedUser() async {
    return await _repository.getAuthenticatedUser();
  }

  /// Refresh the access token.
  ///
  /// Returns a [Future] containing a [Either] with a [Failure] or [TokensModel].
  Future<Either<Failure, void>> signOut() async {
    return await _repository.signOut();
  }
}
