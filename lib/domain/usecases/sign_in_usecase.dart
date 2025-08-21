import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/features/auth/data/models/auth_response_model.dart';
import 'package:frontend/features/auth/data/models/sign_in_request_model.dart';

class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, AuthResponseModel>> call(SignInRequestModel request) async {
    return await _repository.signIn(request: request);
  }
}
