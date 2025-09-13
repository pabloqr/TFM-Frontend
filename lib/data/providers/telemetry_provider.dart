import 'package:flutter/foundation.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/domain/usecases/devices_use_cases.dart';
import 'package:frontend/features/common/data/models/telemetry_model.dart';

class DeviceTelemetryData {
  final ProviderState state;
  final Failure? failure;
  final List<TelemetryModel> telemetry;

  DeviceTelemetryData({required this.state, this.failure, required this.telemetry});

  DeviceTelemetryData copyWith({ProviderState? state, Failure? failure, List<TelemetryModel>? telemetry}) {
    return DeviceTelemetryData(
      state: state ?? this.state,
      failure: failure ?? this.failure,
      telemetry: telemetry ?? this.telemetry,
    );
  }
}

class TelemetryProvider extends ChangeNotifier {
  final DevicesUseCases _devicesUseCases;

  TelemetryProvider({required DevicesUseCases devicesUseCases}) : _devicesUseCases = devicesUseCases;

  final Map<int, DeviceTelemetryData> _deviceData = {};

  DeviceTelemetryData? getDeviceData(int deviceId) {
    return _deviceData[deviceId];
  }

  ProviderState getProviderState(int deviceId) {
    return _deviceData[deviceId]?.state ?? ProviderState.initial;
  }

  Failure? getProviderFailure(int deviceId) {
    return _deviceData[deviceId]?.failure;
  }

  List<TelemetryModel> getProviderTelemetry(int deviceId) {
    return _deviceData[deviceId]?.telemetry ?? [];
  }

  void _setProviderState(int deviceId, DeviceTelemetryData newData) {
    _deviceData[deviceId] = newData;
    notifyListeners();
  }

  void _ensureDeviceExists(int deviceId) {
    if (!_deviceData.containsKey(deviceId)) {
      _deviceData[deviceId] = DeviceTelemetryData(state: ProviderState.initial, telemetry: []);
    }
  }

  Future<void> getDeviceTelemetry(int complexId, int deviceId, {Map<String, dynamic>? query}) async {
    _ensureDeviceExists(deviceId);

    final currentState = _deviceData[deviceId]!;

    // Actualizar a estado de carga, manteniendo los datos existentes
    _setProviderState(deviceId, currentState.copyWith(state: ProviderState.loading));

    final result = await _devicesUseCases.getDeviceTelemetry(complexId, deviceId, query: query);

    result.fold(
      (failure) {
        _setProviderState(
          deviceId,
          currentState.copyWith(state: ProviderState.error, failure: failure),
        );
      },
      (telemetryData) {
        _setProviderState(
          deviceId,
          DeviceTelemetryData(
            state: telemetryData.isNotEmpty ? ProviderState.loaded : ProviderState.empty,
            failure: null,
            telemetry: telemetryData,
          ),
        );
      },
    );
  }
}
