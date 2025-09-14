import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/features/common/data/models/availability_status.dart';
import 'package:frontend/features/reservations/data/models/reservation_model.dart';
import 'package:frontend/features/reservations/data/services/reservations_remote_service.dart';

abstract class ReservationsRepository {
  Future<Either<Failure, List<ReservationModel>>> getReservations({Map<String, dynamic>? query});

  Future<Either<Failure, ReservationModel>> getReservation(int reservationId);

  Future<Either<Failure, List<ReservationModel>>> getUserReservations(int userId, {Map<String, dynamic>? query});

  Future<Either<Failure, List<ReservationModel>>> getComplexReservations(int complexId, {Map<String, dynamic>? query});

  Future<Either<Failure, ReservationModel>> createReservation(ReservationModel reservation);

  Future<Either<Failure, ReservationModel>> updateReservation(ReservationModel reservation);

  Future<Either<Failure, void>> deleteReservation(int reservationId);

  Future<Either<Failure, ReservationModel>> setReservationStatus(
    int reservationId,
    AvailabilityStatus status,
  );
}

class ReservationsRepositoryImpl implements ReservationsRepository {
  final ReservationsRemoteService _remoteService;

  ReservationsRepositoryImpl({required ReservationsRemoteService remoteService}) : _remoteService = remoteService;

  @override
  Future<Either<Failure, List<ReservationModel>>> getReservations({Map<String, dynamic>? query}) async {
    try {
      final response = await _remoteService.getReservations(query: query);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error in repository getting reservations: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ReservationModel>> getReservation(int reservationId) async {
    try {
      final response = await _remoteService.getReservation(reservationId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error in repository getting reservation: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ReservationModel>>> getUserReservations(int userId, {Map<String, dynamic>? query}) async {
    try {
      final response = await _remoteService.getUserReservations(userId, query: query);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(
        UnexpectedFailure(message: 'Unexpected error in repository getting user reservations: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ReservationModel>>> getComplexReservations(
    int complexId, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _remoteService.getComplexReservations(complexId, query: query);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(
        UnexpectedFailure(message: 'Unexpected error in repository getting complex reservations: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ReservationModel>> createReservation(ReservationModel reservation) async {
    try {
      final response = await _remoteService.createReservation(reservation);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error in repository creating reservation: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ReservationModel>> updateReservation(ReservationModel reservation) async {
    try {
      final response = await _remoteService.updateReservation(reservation);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error in repository updating reservation: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReservation(int reservationId) async {
    try {
      await _remoteService.deleteReservation(reservationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error in repository deleting reservation: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ReservationModel>> setReservationStatus(
    int reservationId,
    AvailabilityStatus status,
  ) async {
    try {
      final response = await _remoteService.setReservationStatus(reservationId, status);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(
        UnexpectedFailure(message: 'Unexpected error in repository setting reservation status: ${e.toString()}'),
      );
    }
  }
}
