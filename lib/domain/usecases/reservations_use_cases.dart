import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/repositories/reservations_repository.dart';
import 'package:frontend/features/reservations/data/models/reservation_model.dart';

class ReservationsUseCases {
  final ReservationsRepository _repository;

  ReservationsUseCases({required ReservationsRepository repository}) : _repository = repository;

  Future<Either<Failure, List<ReservationModel>>> getReservations({Map<String, dynamic>? query}) async {
    return await _repository.getReservations(query: query);
  }

  Future<Either<Failure, ReservationModel>> getReservation(int reservationId) async {
    return await _repository.getReservation(reservationId);
  }

  Future<Either<Failure, List<ReservationModel>>> getUserReservations(int userId, {Map<String, dynamic>? query}) async {
    return await _repository.getUserReservations(userId, query: query);
  }

  Future<Either<Failure, List<ReservationModel>>> getComplexReservations(
    int complexId, {
    Map<String, dynamic>? query,
  }) async {
    return await _repository.getComplexReservations(complexId, query: query);
  }

  Future<Either<Failure, ReservationModel>> createReservation(ReservationModel reservation) async {
    return await _repository.createReservation(reservation);
  }

  Future<Either<Failure, ReservationModel>> updateReservation(ReservationModel reservation) async {
    return await _repository.updateReservation(reservation);
  }

  Future<Either<Failure, void>> deleteReservation(int reservationId) async {
    return await _repository.deleteReservation(reservationId);
  }

  Future<Either<Failure, ReservationModel>> setReservationStatus(
    int reservationId,
    ReservationAvailabilityStatus status,
  ) async {
    return await _repository.setReservationStatus(reservationId, status);
  }
}
