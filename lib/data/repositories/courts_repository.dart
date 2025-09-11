import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/features/courts/data/models/court_model.dart';
import 'package:frontend/features/courts/data/services/courts_remote_service.dart';

abstract class CourtsRepository {
  Future<Either<Failure, List<CourtModel>>> getCourts(int complexId, {Map<String, dynamic>? query});
}

class CourtsRepositoryImpl implements CourtsRepository {
  final CourtsRemoteService _remoteService;

  CourtsRepositoryImpl({required CourtsRemoteService remoteService}) : _remoteService = remoteService;

  @override
  Future<Either<Failure, List<CourtModel>>> getCourts(int complexId, {Map<String, dynamic>? query}) async {
    try {
      final response = await _remoteService.getCourts(complexId, query: query);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error during getting courts: ${e.toString()}'));
    }
  }
}