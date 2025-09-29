import 'package:flutter/foundation.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/domain/usecases/reservations_use_cases.dart';
import 'package:frontend/features/reservations/data/models/reservation_model.dart';

class ReservationsListProvider extends ChangeNotifier {
  final ReservationsUseCases _reservationsUseCases;

  ReservationsListProvider({required ReservationsUseCases reservationsUseCases})
    : _reservationsUseCases = reservationsUseCases;

  ProviderState _state = ProviderState.initial;
  Failure? _failure;
  List<ReservationModel> _reservations = [];

  ProviderState get state => _state;

  Failure? get failure => _failure;

  List<ReservationModel> get reservations => _reservations;

  set state(ProviderState value) {
    _state = value;
    notifyListeners();
  }

  Future<void> getReservations() async {
    final bool isInitialLoad = _reservations.isEmpty || _state == ProviderState.error;
    if (isInitialLoad) {
      state = ProviderState.loading;
    }

    final result = await _reservationsUseCases.getReservations();
    result.fold(
      (failure) {
        _failure = failure;
        if (isInitialLoad) {
          state = ProviderState.error;
        }
      },
      (value) {
        _reservations = value;
        _failure = null;
        state = reservations.isNotEmpty ? ProviderState.loaded : ProviderState.empty;
      },
    );
  }

  Future<void> getUserReservations(int userId) async {
    final bool isInitialLoad = _reservations.isEmpty || _state == ProviderState.error;
    if (isInitialLoad) {
      state = ProviderState.loading;
    }

    final result = await _reservationsUseCases.getUserReservations(userId);
    result.fold(
      (failure) {
        _failure = failure;
        if (isInitialLoad) {
          state = ProviderState.error;
        }
      },
      (value) {
        _reservations = value;
        _failure = null;
        state = reservations.isNotEmpty ? ProviderState.loaded : ProviderState.empty;
      },
    );
  }

  Future<void> getComplexReservations(int complexId) async {
    final bool isInitialLoad = _reservations.isEmpty || _state == ProviderState.error;
    if (isInitialLoad) {
      state = ProviderState.loading;
    }

    final result = await _reservationsUseCases.getComplexReservations(complexId);
    result.fold(
      (failure) {
        _failure = failure;
        if (isInitialLoad) {
          state = ProviderState.error;
        }
      },
      (value) {
        _reservations = value;
        _failure = null;
        state = reservations.isNotEmpty ? ProviderState.loaded : ProviderState.empty;
      },
    );
  }
}
