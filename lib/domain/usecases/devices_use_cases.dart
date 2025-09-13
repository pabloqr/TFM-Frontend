import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/repositories/devices_repository.dart';
import 'package:frontend/features/common/data/models/telemetry_model.dart';
import 'package:frontend/features/devices/data/models/device_model.dart';

class DevicesUseCases {
  final DevicesRepository _repository;

  DevicesUseCases({required DevicesRepository repository}) : _repository = repository;

  Future<Either<Failure, List<DeviceModel>>> getDevices(int complexId, {Map<String, dynamic>? query}) async {
    return await _repository.getDevices(complexId, query: query);
  }

  Future<Either<Failure, DeviceModel>> getDevice(int complexId, int deviceId) async {
    return await _repository.getDevice(complexId, deviceId);
  }

  Future<Either<Failure, DeviceModel>> createDevice(int complexId, DeviceModel device) async {
    return await _repository.createDevice(complexId, device);
  }

  Future<Either<Failure, DeviceModel>> updateDevice(int complexId, int deviceId, DeviceModel device) async {
    return await _repository.updateDevice(complexId, deviceId, device);
  }

  Future<Either<Failure, void>> deleteDevice(int complexId, int deviceId) async {
    return await _repository.deleteDevice(complexId, deviceId);
  }

  Future<Either<Failure, List<TelemetryModel>>> getDeviceTelemetry(
    int complexId,
    int deviceId, {
    Map<String, dynamic>? query,
  }) async {
    return await _repository.getDeviceTelemetry(complexId, deviceId, query: query);
  }

  Future<Either<Failure, List<TelemetryModel>>> setDeviceTelemetry(
    int complexId,
    int deviceId,
    TelemetryModel telemetry,
  ) async {
    return await _repository.setDeviceTelemetry(complexId, deviceId, telemetry);
  }
}
