import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/features/auth/data/models/sign_in_request_model.dart';
import 'package:frontend/features/auth/data/models/sign_up_request_model.dart';
import 'package:frontend/features/auth/data/models/auth_response_model.dart';
import 'package:frontend/features/auth/data/services/auth_local_service.dart';
import 'package:frontend/features/auth/data/services/auth_remote_service.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponseModel>> signUp({required SignUpRequestModel request});

  Future<Either<Failure, AuthResponseModel>> signIn({required SignInRequestModel request});
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteService _remoteService;
  final AuthLocalService _localService;

  AuthRepositoryImpl({required AuthRemoteService remoteService, required AuthLocalService localService})
    : _remoteService = remoteService,
      _localService = localService;

  @override
  Future<Either<Failure, AuthResponseModel>> signUp({required SignUpRequestModel request}) async {
    try {
      final response = await _remoteService.signUp(request);

      try {
        await _localService.saveAccessToken(response.accessToken);
        await _localService.saveRefreshToken(response.refreshToken);
        await _localService.saveUser(response.user);
      } catch (e) {
        return Left(CacheFailure(message: 'Failed to save data after sign up: ${e.toString()}'));
      }

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
  Future<Either<Failure, AuthResponseModel>> signIn({required SignInRequestModel request}) async {
    try {
      final response = await _remoteService.signIn(request);

      try {
        await _localService.saveAccessToken(response.accessToken);
        await _localService.saveRefreshToken(response.refreshToken);
        await _localService.saveUser(response.user);
      } catch (e) {
        return Left(CacheFailure(message: 'Failed to save data after sign in: ${e.toString()}'));
      }

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
}
