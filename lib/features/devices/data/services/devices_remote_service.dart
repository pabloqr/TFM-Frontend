import 'dart:async';
import 'dart:convert';

import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/data/services/authenticated_http_client.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/features/common/data/models/telemetry_model.dart';
import 'package:frontend/features/devices/data/models/device_model.dart';

abstract class DevicesRemoteService {
  Future<List<DeviceModel>> getDevices(int complexId, {Map<String, dynamic>? query});

  Future<DeviceModel> getDevice(int complexId, int deviceId);

  Future<DeviceModel> createDevice(int complexId, DeviceModel device);

  Future<DeviceModel> updateDevice(int complexId, int deviceId, DeviceModel device);

  Future<void> deleteDevice(int complexId, int deviceId);

  Future<List<TelemetryModel>> getDeviceTelemetry(int complexId, int deviceId, {Map<String, dynamic>? query});

  Future<List<TelemetryModel>> setDeviceTelemetry(int complexId, int deviceId, TelemetryModel telemetry);
}

class DevicesRemoteServiceImpl implements DevicesRemoteService {
  static const Map<String, Type> _queryValidator = {
    'id': int,
    'complexId': String,
    'type': String,
    'status': DeviceStatus,
    'courts': List<int>,
    'createdAt': DateTime,
    'updatedAt': DateTime,
  };

  static const Map<String, Type> _telemetryQueryValidator = {
    'minValue': double,
    'maxValue': double,
    'last': bool,
    'minDate': DateTime,
    'maxDate': DateTime,
    'createdAt': DateTime,
  };

  final AuthenticatedHttpClient _client;

  DevicesRemoteServiceImpl({required AuthenticatedHttpClient client}) : _client = client;

  @override
  Future<List<DeviceModel>> getDevices(int complexId, {Map<String, dynamic>? query}) async {
    Uri uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.devicesCREndpoint(complexId.toString())}');

    if (query != null && query.isNotEmpty) {
      Map<String, String> queryParameters = {};
      query.forEach((key, value) {
        if (!_queryValidator.containsKey(key)) return;

        Type type = _queryValidator[key]!;
        String? valueString = NetworkUtilities.validateQueryValue(type: type, value: value);

        if (valueString != null) queryParameters[key] = valueString;
      });

      uri.replace(queryParameters: queryParameters);
    }

    try {
      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data;
        try {
          data = json.decode(utf8.decode(response.bodyBytes));
        } catch (e) {
          throw UnexpectedException(message: 'Error decoding response body: ${e.toString()}');
        }

        return data.map((e) => DeviceModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        final Map<String, dynamic> data;
        try {
          data = json.decode(utf8.decode(response.bodyBytes));
        } catch (e) {
          throw UnexpectedException(message: 'Error decoding response body: ${e.toString()}');
        }

        throw ServerException(
          message: data['message'] ?? 'Error getting devices: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(message: 'Network error getting devices: ${e.toString()}');
    }
  }

  @override
  Future<DeviceModel> getDevice(int complexId, int deviceId) async {
    Uri uri = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.devicesUDEndpoint(complexId.toString(), deviceId.toString())}',
    );

    try {
      final response = await _client.get(uri);

      final Map<String, dynamic> data;
      try {
        data = json.decode(utf8.decode(response.bodyBytes));
      } catch (e) {
        throw UnexpectedException(message: 'Error decoding response body: ${e.toString()}');
      }

      if (response.statusCode == 200) {
        return DeviceModel.fromJson(data);
      } else {
        throw ServerException(
          message: data['message'] ?? 'Error getting device: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(message: 'Network error getting device: ${e.toString()}');
    }
  }

  @override
  Future<DeviceModel> createDevice(int complexId, DeviceModel device) async {
    Uri uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.devicesCREndpoint(complexId.toString())}');

    try {
      final response = await _client.post(uri, body: device.toJsonString());

      final Map<String, dynamic> data;
      try {
        data = json.decode(utf8.decode(response.bodyBytes));
      } catch (e) {
        throw UnexpectedException(message: 'Error decoding response body: ${e.toString()}');
      }

      if (response.statusCode == 201) {
        return DeviceModel.fromJson(data);
      } else {
        throw ServerException(
          message: data['message'] ?? 'Error creating device: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException catch (e) {
      throw NetworkException(message: 'Connection timeout during device creation: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(message: 'Network error creating device: ${e.toString()}');
    }
  }

  @override
  Future<DeviceModel> updateDevice(int complexId, int deviceId, DeviceModel device) async {
    // TODO: implement updateDevice
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDevice(int complexId, int deviceId) async {
    // TODO: implement deleteDevice
    throw UnimplementedError();
  }

  @override
  Future<List<TelemetryModel>> getDeviceTelemetry(int complexId, int deviceId, {Map<String, dynamic>? query}) async {
    Uri uri = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.devicesTelemetryEndpoint(complexId.toString(), deviceId.toString())}',
    );

    if (query != null && query.isNotEmpty) {
      Map<String, String> queryParameters = {};
      query.forEach((key, value) {
        if (!_telemetryQueryValidator.containsKey(key)) return;

        Type type = _telemetryQueryValidator[key]!;
        String? valueString = NetworkUtilities.validateQueryValue(type: type, value: value);

        if (valueString != null) queryParameters[key] = valueString;
      });

      uri.replace(queryParameters: queryParameters);
    }

    try {
      final response = await _client.get(uri);

      final Map<String, dynamic> data;
      try {
        data = json.decode(utf8.decode(response.bodyBytes));
      } catch (e) {
        throw UnexpectedException(message: 'Error decoding response body: ${e.toString()}');
      }

      if (response.statusCode == 200) {
        if (data['telemetry'] is List) {
          final List<dynamic> telemetryData = data['telemetry'] as List<dynamic>;
          return telemetryData.map<TelemetryModel>((e) {
            return TelemetryModel.fromJson(e as Map<String, dynamic>);
          }).toList();
        } else {
          throw UnexpectedException(message: 'Expected a list of telemetry, but got: ${data['devices'].runtimeType}');
        }
      } else {
        throw ServerException(
          message: data['message'] ?? 'Error getting device telemetry: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(message: 'Network error getting device telemetry: ${e.toString()}');
    }
  }

  @override
  Future<List<TelemetryModel>> setDeviceTelemetry(int complexId, int deviceId, TelemetryModel telemetry) async {
    // TODO: implement setDeviceTelemetry
    throw UnimplementedError();
  }
}
