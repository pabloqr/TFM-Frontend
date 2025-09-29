import 'package:flutter/foundation.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/domain/usecases/complexes_use_cases.dart';
import 'package:frontend/features/complexes/data/models/complex_model.dart';

class ComplexesListProvider extends ChangeNotifier {
  final ComplexesUseCases _complexesUseCases;

  ComplexesListProvider({required ComplexesUseCases complexesUseCases}) : _complexesUseCases = complexesUseCases;

  ProviderState _state = ProviderState.initial;
  Failure? _failure;
  List<ComplexModel> _complexes = [];

  ProviderState get state => _state;

  Failure? get failure => _failure;

  List<ComplexModel> get complexes => _complexes;

  set state(ProviderState value) {
    _state = value;
    notifyListeners();
  }

  Future<void> getComplexes() async {
    final bool isInitialLoad = _complexes.isEmpty || _state == ProviderState.error;

    if (isInitialLoad) {
      state = ProviderState.loading;
    }

    final result = await _complexesUseCases.getComplexes();
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
        _complexes = value;
        // Clear any previous failure on successful fetch
        _failure = null;
        state = complexes.isNotEmpty ? ProviderState.loaded : ProviderState.empty;
      },
    );
  }
}
