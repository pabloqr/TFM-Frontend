import 'package:flutter/foundation.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/domain/usecases/reservations_use_cases.dart';
import 'package:frontend/features/common/data/models/availability_status.dart';
import 'package:frontend/features/reservations/data/models/reservation_model.dart';

class ReservationProvider extends ChangeNotifier {
  final ReservationsUseCases _reservationsUseCases;

  ReservationProvider({required ReservationsUseCases reservationsUseCases})
    : _reservationsUseCases = reservationsUseCases;

  ProviderState _state = ProviderState.initial;
  Failure? _failure;
  ReservationModel _reservation = ReservationModel(
    id: -1,
    userId: -1,
    complexId: -1,
    courtId: -1,
    dateIni: DateTime.now(),
    dateEnd: DateTime.now(),
    status: AvailabilityStatus.empty,
    reservationStatus: ReservationStatus.scheduled,
    timeFilter: TimeFilter.upcoming,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  ProviderState get state => _state;

  Failure? get failure => _failure;

  ReservationModel get reservation => _reservation;

  set state(ProviderState value) {
    _state = value;
    notifyListeners();
  }

  Future<void> getReservation(int reservationId) async {
    final bool isInitialLoad = _reservation.id == -1 || _state == ProviderState.error;
    if (isInitialLoad) {
      state = ProviderState.loading;
    }

    final result = await _reservationsUseCases.getReservation(reservationId);
    result.fold(
      (failure) {
        _failure = failure;
        if (isInitialLoad) {
          state = ProviderState.error;
        }
      },
      (value) {
        _reservation = value;
        _failure = null;
        state = ProviderState.loaded;
      },
    );
  }
}
