import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/features/auth/data/models/sign_up_request_model.dart';
import 'package:frontend/features/auth/data/models/auth_response_model.dart';
import 'package:frontend/data/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, AuthResponseModel>> call(SignUpRequestModel request) async {
    return await _repository.signUp(request: request);
  }
}
