import 'package:flutter/foundation.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/domain/usecases/complexes_use_cases.dart';
import 'package:frontend/features/complexes/data/models/complex_model.dart';

class ComplexProvider extends ChangeNotifier {
  final ComplexesUseCases _complexesUseCases;

  ComplexProvider({required ComplexesUseCases complexesUseCases}) : _complexesUseCases = complexesUseCases;

  ProviderState _state = ProviderState.initial;
  Failure? _failure;
  ComplexModel _complex = ComplexModel(
    id: -1,
    complexName: 'Complex',
    timeIni: '00:00',
    timeEnd: '00:00',
    locLongitude: null,
    locLatitude: null,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  ProviderState get state => _state;

  Failure? get failure => _failure;

  ComplexModel get complex => _complex;

  set state(ProviderState value) {
    _state = value;
    notifyListeners();
  }

  Future<void> getComplex(int complexId) async {
    final bool isInitialLoad = _complex.id == -1 || _state == ProviderState.error;

    if (isInitialLoad) {
      state = ProviderState.loading;
    }

    final result = await _complexesUseCases.getComplex(complexId);
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
        _complex = value;
        // Clear any previous failure on successful fetch
        _failure = null;
        state = _complex.id != -1 ? ProviderState.loaded : ProviderState.empty;
      },
    );
  }
}
