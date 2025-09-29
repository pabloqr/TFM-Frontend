import 'dart:convert';

import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/data/services/authenticated_http_client.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/features/courts/data/models/court_availability_model.dart';
import 'package:frontend/features/courts/data/models/court_model.dart';
import 'package:frontend/features/devices/data/models/device_model.dart';

abstract class CourtsRemoteService {
  Future<List<CourtModel>> getCourts(int complexId, {Map<String, dynamic>? query});

  Future<CourtModel> getCourt(int complexId, int courtId);

  Future<CourtAvailabilityModel> getCourtAvailability(int complexId, int courtId);

  Future<List<DeviceModel>> getCourtDevices(int complexId, int courtId);
}

class CourtsRemoteServiceImpl implements CourtsRemoteService {
  static const Map<String, Type> _queryValidator = {
    'id': int,
    'sport': String,
    'name': String,
    'description': String,
    'maxPeople': int,
    'status': String,
    'createdAt': DateTime,
    'updatedAt': DateTime,
  };

  final AuthenticatedHttpClient _client;

  CourtsRemoteServiceImpl({required AuthenticatedHttpClient client}) : _client = client;

  @override
  Future<List<CourtModel>> getCourts(int complexId, {Map<String, dynamic>? query}) async {
    Uri uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.courtsCREndpoint(complexId.toString())}');

    if (query != null && query.isNotEmpty) {
      Map<String, String> queryParameters = {};
      query.forEach((key, value) {
        if (!_queryValidator.containsKey(key)) return;

        Type type = _queryValidator[key]!;
        String? valueString = NetworkUtilities.validateQueryValue(type: type, value: value);

        if (valueString != null) queryParameters[key] = valueString;
      });

      uri = uri.replace(queryParameters: queryParameters);
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

        return data.map((e) => CourtModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        final Map<String, dynamic> data;
        try {
          data = json.decode(utf8.decode(response.bodyBytes));
        } catch (e) {
          throw UnexpectedException(message: 'Error decoding response body: ${e.toString()}');
        }

        throw ServerException(
          message: data['message'] ?? 'Error getting courts: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(message: 'Network error getting courts: ${e.toString()}');
    }
  }

  @override
  Future<CourtModel> getCourt(int complexId, int courtId) async {
    Uri uri = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.courtsUDEndpoint(complexId.toString(), courtId.toString())}',
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
        return CourtModel.fromJson(data);
      } else {
        throw ServerException(
          message: data['message'] ?? 'Error getting court: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(message: 'Network error getting court: ${e.toString()}');
    }
  }

  @override
  Future<CourtAvailabilityModel> getCourtAvailability(int complexId, int courtId) async {
    Uri uri = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.courtAvailabilityEndpoint(complexId.toString(), courtId.toString())}',
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
        return CourtAvailabilityModel.fromJson(data);
      } else {
        throw ServerException(
          message: data['message'] ?? 'Error getting court availability: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(message: 'Network error getting court availability: ${e.toString()}');
    }
  }

  @override
  Future<List<DeviceModel>> getCourtDevices(int complexId, int courtId) async {
    Uri uri = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.courtDevicesEndpoint(complexId.toString(), courtId.toString())}',
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
        if (data['devices'] is List) {
          final List<dynamic> devicesData = data['devices'] as List<dynamic>;
          return devicesData.map<DeviceModel>((e) {
            return DeviceModel.fromJson(e as Map<String, dynamic>);
          }).toList();
        } else {
          throw UnexpectedException(message: 'Expected a list of devices, but got: ${data['devices'].runtimeType}');
        }
      } else {
        throw ServerException(
          message: data['message'] ?? 'Error getting devices: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnexpectedException) rethrow;
      throw NetworkException(message: 'Network error getting devices: ${e.toString()}');
    }
  }
}
