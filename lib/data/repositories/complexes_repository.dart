import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/features/complexes/data/models/complex_model.dart';
import 'package:frontend/features/complexes/data/services/complexes_remote_service.dart';

abstract class ComplexesRepository {
  Future<Either<Failure, List<ComplexModel>>> getComplexes({Map<String, dynamic>? query});

  Future<Either<Failure, ComplexModel>> getComplex(int complexId);
}

class ComplexesRepositoryImpl implements ComplexesRepository {
  final ComplexesRemoteService _remoteService;

  ComplexesRepositoryImpl({required ComplexesRemoteService remoteService}) : _remoteService = remoteService;

  @override
  Future<Either<Failure, List<ComplexModel>>> getComplexes({Map<String, dynamic>? query}) async {
    try {
      final response = await _remoteService.getComplexes(query: query);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error during getting complexes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ComplexModel>> getComplex(int complexId) async {
    try {
      final response = await _remoteService.getComplex(complexId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error during getting complex: ${e.toString()}'));
    }
  }
}
