import 'package:flutter/foundation.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/domain/usecases/complexes_use_cases.dart';
import 'package:frontend/features/complexes/data/models/complex_model.dart';

enum ComplexesState { initial, loading, loaded, empty, error }

class ComplexesProvider extends ChangeNotifier {
  final ComplexesUseCases _complexesUseCases;

  ComplexesProvider({required ComplexesUseCases complexesUseCases}) : _complexesUseCases = complexesUseCases;

  ComplexesState _state = ComplexesState.initial;
  Failure? _failure;
  List<ComplexModel> _complexes = [];

  ComplexesState get state => _state;
  Failure? get failure => _failure;
  List<ComplexModel> get complexes => _complexes;

  set state(ComplexesState value) {
    _state = value;
    notifyListeners();
  }

  Future<void> getComplexes() async {
    state = ComplexesState.loading;

    final result = await _complexesUseCases.getComplexes();
    result.fold(
      (failure) {
        _failure = failure;
        state = ComplexesState.error;
      },
      (value) {
        _complexes = value;
        state = complexes.isNotEmpty ? ComplexesState.loaded : ComplexesState.empty;
      },
    );
  }
}
