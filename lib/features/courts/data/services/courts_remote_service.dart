import 'dart:convert';

import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/data/services/authenticated_http_client.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/features/courts/data/models/court_model.dart';
import 'package:frontend/features/courts/data/models/court_status_model.dart';
import 'package:frontend/features/courts/data/models/sport_enum.dart';

abstract class CourtsRemoteService {
  Future<List<CourtModel>> getCourts(int complexId, {Map<String, dynamic>? query});
}

class CourtsRemoteServiceImpl implements CourtsRemoteService {
  static const Map<String, Type> _queryValidator = {
    'id': int,
    'sport': Sport,
    'name': String,
    'description': String,
    'maxPeople': int,
    'status': CourtStatus,
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

        return data.map((e) => CourtModel.fromJson(e)).toList();
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
}
