import 'package:flutter/foundation.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/domain/usecases/courts_use_cases.dart';
import 'package:frontend/features/courts/data/models/court_availability_model.dart';

class AvailabilityProvider extends ChangeNotifier {
  final CourtsUseCases _courtsUseCases;

  AvailabilityProvider({required CourtsUseCases courtsUseCases}) : _courtsUseCases = courtsUseCases;

  ProviderState _state = ProviderState.initial;
  Failure? _failure;
  CourtAvailabilityModel _availability = CourtAvailabilityModel(id: -1, complexId: -1, availability: []);

  ProviderState get state => _state;

  Failure? get failure => _failure;

  CourtAvailabilityModel get availability => _availability;

  set state(ProviderState value) {
    _state = value;
    notifyListeners();
  }

  Future<void> getCourtAvailability(int complexId, int courtId) async {
    final bool isInitialLoad = _availability.id == -1 || _state == ProviderState.error;

    if (isInitialLoad) {
      state = ProviderState.loading;
    }

    final result = await _courtsUseCases.getCourtAvailability(complexId, courtId);
    result.fold(
      (failure) {
        _failure = failure;
        // Only set to error state if it was an initial load or retrying from an error state.
        // Otherwise, keep the existing (stale) data visible.
        if (isInitialLoad) {
          state = ProviderState.error;
        }
      },
      (value) {
        _availability = value;
        // Clear any previous failure on successful fetch
        _failure = null;
        state = _availability.id != -1 ? ProviderState.loaded : ProviderState.empty;
      },
    );
  }
}
