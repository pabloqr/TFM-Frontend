import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/features/auth/data/models/model_sign_up_request.dart';
import 'package:frontend/features/auth/data/models/model_auth_response.dart';
import 'package:frontend/data/repositories/repository_auth.dart';

class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, AuthResponseModel>> call(SignUpRequestModel request) async {
    return await _repository.signUp(request: request);
  }
}
