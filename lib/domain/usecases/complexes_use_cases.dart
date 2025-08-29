import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/repositories/complexes_repository.dart';
import 'package:frontend/features/complexes/data/models/complex_model.dart';

class ComplexesUseCases {
  final ComplexesRepository _repository;

  ComplexesUseCases({required ComplexesRepository repository}) : _repository = repository;

  Future<Either<Failure, List<ComplexModel>>> getComplexes({Map<String, dynamic>? query}) async {
    return await _repository.getComplexes(query: query);
  }
}