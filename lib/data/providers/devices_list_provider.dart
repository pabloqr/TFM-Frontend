import 'package:flutter/foundation.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/domain/usecases/courts_use_cases.dart';
import 'package:frontend/features/devices/data/models/device_model.dart';

class DevicesListProvider extends ChangeNotifier {
  final CourtsUseCases _courtsUseCases;

  DevicesListProvider({required CourtsUseCases courtsUseCases}) : _courtsUseCases = courtsUseCases;

  ProviderState _state = ProviderState.initial;
  Failure? _failure;
  List<DeviceModel> _devices = [];

  ProviderState get state => _state;

  Failure? get failure => _failure;

  List<DeviceModel> get devices => _devices;

  set state(ProviderState value) {
    _state = value;
    notifyListeners();
  }

  Future<void> getDevices(int complexId, int courtId) async {
    final bool isInitialLoad = _devices.isEmpty || _state == ProviderState.error;

    if (isInitialLoad) {
      state = ProviderState.loading;
    }

    final result = await _courtsUseCases.getDevices(complexId, courtId);
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
        _devices = value;
        // Clear any previous failure on successful fetch
        _failure = null;
        state = devices.isNotEmpty ? ProviderState.loaded : ProviderState.empty;
      },
    );
  }
}
