import 'package:flutter/foundation.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/domain/usecases/courts_use_cases.dart';
import 'package:frontend/domain/usecases/devices_use_cases.dart';
import 'package:frontend/features/devices/data/models/device_model.dart';

class DevicesListProvider extends ChangeNotifier {
  final DevicesUseCases _devicesUseCases;
  final CourtsUseCases _courtsUseCases;

  DevicesListProvider({required DevicesUseCases devicesUseCases, required CourtsUseCases courtsUseCases})
    : _devicesUseCases = devicesUseCases,
      _courtsUseCases = courtsUseCases;

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

  Future<void> getDevices(int complexId) async {
    state = ProviderState.loading;
    _devices = [];

    final result = await _devicesUseCases.getDevices(complexId);
    result.fold(
      (failure) {
        _failure = failure;
        // Only set to error state if it was an initial load or retrying from an error state.
        // Otherwise, keep the existing (stale) data visible.
        state = ProviderState.error;
      },
      (value) {
        _devices = value;
        // Clear any previous failure on successful fetch
        _failure = null;
        state = devices.isNotEmpty ? ProviderState.loaded : ProviderState.empty;
      },
    );
  }

  Future<void> getCourtDevices(int complexId, int courtId) async {
    state = ProviderState.loading;
    _devices = [];

    final result = await _courtsUseCases.getCourtDevices(complexId, courtId);
    result.fold(
      (failure) {
        _failure = failure;
        // Only set to error state if it was an initial load or retrying from an error state.
        // Otherwise, keep the existing (stale) data visible.
        state = ProviderState.error;
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
