import 'package:flutter/foundation.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/domain/usecases/courts_use_cases.dart';
import 'package:frontend/features/courts/data/models/court_model.dart';

class CourtsListProvider extends ChangeNotifier {
  final CourtsUseCases _courtsUseCases;

  CourtsListProvider({required CourtsUseCases courtsUseCases}) : _courtsUseCases = courtsUseCases;

  ProviderState _state = ProviderState.initial;
  Failure? _failure;
  List<CourtModel> _courts = [];

  ProviderState get state => _state;

  Failure? get failure => _failure;

  List<CourtModel> get courts => _courts;

  set state(ProviderState value) {
    _state = value;
    notifyListeners();
  }

  Future<void> getCourts(int complexId) async {
    final bool isInitialLoad = _courts.isEmpty || _state == ProviderState.error;

    if (isInitialLoad) {
      state = ProviderState.loading;
    }

    final result = await _courtsUseCases.getCourts(complexId);
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
        _courts = value;
        // Clear any previous failure on successful fetch
        _failure = null;
        state = courts.isNotEmpty ? ProviderState.loaded : ProviderState.empty;
      },
    );
  }
}
