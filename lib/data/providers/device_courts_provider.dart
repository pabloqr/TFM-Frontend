import 'package:flutter/foundation.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/domain/usecases/devices_use_cases.dart';
import 'package:frontend/features/courts/data/models/court_model.dart';

class DeviceCourtsData {
  final ProviderState state;
  final Failure? failure;
  final List<CourtModel> courts;

  DeviceCourtsData({required this.state, this.failure, required this.courts});

  DeviceCourtsData copyWith({ProviderState? state, Failure? failure, List<CourtModel>? courts}) {
    return DeviceCourtsData(
      state: state ?? this.state,
      failure: failure ?? this.failure,
      courts: courts ?? this.courts,
    );
  }
}

class DeviceCourtsProvider extends ChangeNotifier {
  final DevicesUseCases _devicesUseCases;

  DeviceCourtsProvider({required DevicesUseCases devicesUseCases}) : _devicesUseCases = devicesUseCases;

  final Map<int, DeviceCourtsData> _deviceData = {};

  DeviceCourtsData? getDeviceData(int deviceId) {
    return _deviceData[deviceId];
  }

  ProviderState getProviderState(int deviceId) {
    return _deviceData[deviceId]?.state ?? ProviderState.initial;
  }

  Failure? getProviderFailure(int deviceId) {
    return _deviceData[deviceId]?.failure;
  }

  List<CourtModel> getProviderCourts(int deviceId) {
    return _deviceData[deviceId]?.courts ?? [];
  }

  void _setProviderState(int deviceId, DeviceCourtsData newData) {
    _deviceData[deviceId] = newData;
    notifyListeners();
  }

  void _ensureDeviceExists(int deviceId) {
    if (!_deviceData.containsKey(deviceId)) {
      _deviceData[deviceId] = DeviceCourtsData(state: ProviderState.initial, courts: []);
    }
  }

  Future<void> getDeviceCourts(int complexId, int deviceId, {Map<String, dynamic>? query}) async {
    _ensureDeviceExists(deviceId);

    final currentState = _deviceData[deviceId]!;

    // Actualizar a estado de carga, manteniendo los datos existentes
    _setProviderState(deviceId, currentState.copyWith(state: ProviderState.loading));

    final result = await _devicesUseCases.getDeviceCourts(complexId, deviceId);

    result.fold(
      (failure) {
        _setProviderState(deviceId, currentState.copyWith(state: ProviderState.error, failure: failure));
      },
      (telemetryData) {
        _setProviderState(
          deviceId,
          DeviceCourtsData(
            state: telemetryData.isNotEmpty ? ProviderState.loaded : ProviderState.empty,
            failure: null,
            courts: telemetryData,
          ),
        );
      },
    );
  }
}
