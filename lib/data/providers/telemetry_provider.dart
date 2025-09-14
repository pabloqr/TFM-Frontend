import 'package:flutter/foundation.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/models/provider_state_enum.dart';
import 'package:frontend/domain/usecases/courts_use_cases.dart';
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
  final CourtsUseCases _courtsUseCases;

  TelemetryProvider({required DevicesUseCases devicesUseCases, required CourtsUseCases courtsUseCases})
    : _devicesUseCases = devicesUseCases,
      _courtsUseCases = courtsUseCases;

  ProviderState _state = ProviderState.loaded;
  Failure? _failure;
  List<int> _ids = [];
  final Map<int, DeviceTelemetryData> _data = {};

  ProviderState get state => _state;

  Failure? get failure => _failure;

  List<int> get ids => _ids;

  DeviceTelemetryData? getDeviceData(int id) {
    return _data[id];
  }

  ProviderState getDataState(int id) {
    return _data[id]?.state ?? ProviderState.initial;
  }

  Failure? getDataFailure(int id) {
    return _data[id]?.failure;
  }

  List<TelemetryModel> getDataTelemetry(int id) {
    return _data[id]?.telemetry ?? [];
  }

  set state(ProviderState value) {
    _state = value;
    notifyListeners();
  }

  void _setDataState(int id, DeviceTelemetryData newData) {
    _data[id] = newData;
    notifyListeners();
  }

  void _ensureTelemetryExists(int id) {
    if (!_data.containsKey(id)) {
      _data[id] = DeviceTelemetryData(state: ProviderState.initial, telemetry: []);
    }
  }

  Future<void> getComplexDevicesTelemetry(int complexId, {Map<String, dynamic>? query}) async {
    _ids = [];
    state = ProviderState.loading;

    final devicesResult = await _devicesUseCases.getDevices(complexId);
    devicesResult.fold(
      (failure) {
        state = ProviderState.error;
        _failure = failure;
      },
      (ids) async {
        for (var id in ids.map((e) => e.id)) {
          getDeviceTelemetry(complexId, id, query: query);
        }

        state = ProviderState.loaded;
        _failure = null;
      },
    );
  }

  Future<void> getCourtDevicesTelemetry(int complexId, int courtId, {Map<String, dynamic>? query}) async {
    _ids = [];
    state = ProviderState.loading;

    final devicesResult = await _courtsUseCases.getCourtDevices(complexId, courtId);
    devicesResult.fold(
      (failure) {
        state = ProviderState.error;
        _failure = failure;
      },
      (ids) async {
        for (var id in ids.map((e) => e.id)) {
          getDeviceTelemetry(complexId, id, query: query);
        }

        state = ProviderState.loaded;
        _failure = null;
      },
    );
  }

  Future<void> getDeviceTelemetry(int complexId, int deviceId, {Map<String, dynamic>? query}) async {
    _ensureTelemetryExists(deviceId);

    final currentState = _data[deviceId]!;

    // Actualizar a estado de carga, manteniendo los datos existentes
    _setDataState(deviceId, currentState.copyWith(state: ProviderState.loading));

    final result = await _devicesUseCases.getDeviceTelemetry(complexId, deviceId, query: query);

    result.fold(
      (failure) {
        _setDataState(deviceId, currentState.copyWith(state: ProviderState.error, failure: failure));
      },
      (telemetryData) {
        _ids.add(deviceId);

        _setDataState(
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
