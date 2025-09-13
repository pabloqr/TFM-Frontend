import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/features/courts/data/models/court_model.dart';
import 'package:frontend/features/courts/data/services/courts_remote_service.dart';
import 'package:frontend/features/devices/data/models/device_model.dart';

abstract class CourtsRepository {
  Future<Either<Failure, List<CourtModel>>> getCourts(int complexId, {Map<String, dynamic>? query});

  Future<Either<Failure, CourtModel>> getCourt(int complexId, int courtId);

  Future<Either<Failure, List<DeviceModel>>> getCourtDevices(int complexId, int courtId);
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

  @override
  Future<Either<Failure, CourtModel>> getCourt(int complexId, int courtId) async {
    try {
      final response = await _remoteService.getCourt(complexId, courtId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error during getting court: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DeviceModel>>> getCourtDevices(int complexId, int courtId) async {
    try {
      final response = await _remoteService.getCourtDevices(complexId, courtId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error during getting devices: ${e.toString()}'));
    }
  }
}
