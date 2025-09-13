import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/features/common/data/models/telemetry_model.dart';
import 'package:frontend/features/devices/data/models/device_model.dart';
import 'package:frontend/features/devices/data/services/devices_remote_service.dart';

abstract class DevicesRepository {
  Future<Either<Failure, List<DeviceModel>>> getDevices(int complexId, {Map<String, dynamic>? query});

  Future<Either<Failure, DeviceModel>> getDevice(int complexId, int deviceId);

  Future<Either<Failure, DeviceModel>> createDevice(int complexId, DeviceModel device);

  Future<Either<Failure, DeviceModel>> updateDevice(int complexId, int deviceId, DeviceModel device);

  Future<Either<Failure, void>> deleteDevice(int complexId, int deviceId);

  Future<Either<Failure, List<TelemetryModel>>> getDeviceTelemetry(
    int complexId,
    int deviceId, {
    Map<String, dynamic>? query,
  });

  Future<Either<Failure, List<TelemetryModel>>> setDeviceTelemetry(
    int complexId,
    int deviceId,
    TelemetryModel telemetry,
  );
}

class DevicesRepositoryImpl implements DevicesRepository {
  final DevicesRemoteService _remoteService;

  DevicesRepositoryImpl({required DevicesRemoteService remoteService}) : _remoteService = remoteService;

  @override
  Future<Either<Failure, List<DeviceModel>>> getDevices(int complexId, {Map<String, dynamic>? query}) async {
    try {
      final response = await _remoteService.getDevices(complexId, query: query);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Unexpected error in repository getting devices: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DeviceModel>> getDevice(int complexId, int deviceId) async {
    // TODO: implement getDevice
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, DeviceModel>> createDevice(int complexId, DeviceModel device) async {
    // TODO: implement createDevice
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, DeviceModel>> updateDevice(int complexId, int deviceId, DeviceModel device) async {
    // TODO: implement updateDevice
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteDevice(int complexId, int deviceId) async {
    // TODO: implement deleteDevice
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<TelemetryModel>>> getDeviceTelemetry(
    int complexId,
    int deviceId, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _remoteService.getDeviceTelemetry(complexId, deviceId, query: query);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(
        UnexpectedFailure(message: 'Unexpected error in repository getting device telemetry: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<TelemetryModel>>> setDeviceTelemetry(
    int complexId,
    int deviceId,
    TelemetryModel telemetry,
  ) async {
    // TODO: implement setDeviceTelemetry
    throw UnimplementedError();
  }
}
