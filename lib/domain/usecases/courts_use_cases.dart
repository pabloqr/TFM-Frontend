import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/repositories/courts_repository.dart';
import 'package:frontend/features/courts/data/models/court_model.dart';

class CourtsUseCases {
  final CourtsRepository _repository;

  CourtsUseCases({required CourtsRepository repository}) : _repository = repository;

  Future<Either<Failure, List<CourtModel>>> getCourts(int complexId, {Map<String, dynamic>? query}) async {
    return await _repository.getCourts(complexId, query: query);
  }
}
