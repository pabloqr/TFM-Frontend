import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/features/auth/data/models/model_sign_up_request.dart';
import 'package:frontend/features/auth/data/models/model_auth_response.dart';
import 'package:frontend/features/auth/data/services/service_local_auth.dart';
import 'package:frontend/features/auth/data/services/service_remote_auth.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponseModel>> signUp({required SignUpRequestModel request});
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
      } catch (e) {
        return Left(CacheFailure(message: 'Failed to save tokens after sign up: ${e.toString()}'));
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
}
