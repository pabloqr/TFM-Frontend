import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/repositories/repository_auth.dart';
import 'package:frontend/features/auth/data/models/model_auth_response.dart';
import 'package:frontend/features/auth/data/models/model_sign_in_request.dart';

class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, AuthResponseModel>> call(SignInRequestModel request) async {
    return await _repository.signIn(request: request);
  }
}
