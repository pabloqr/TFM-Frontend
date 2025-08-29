import 'dart:convert';

import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/data/services/authenticated_http_client.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/features/complexes/data/models/complex_model.dart';

abstract class ComplexesRemoteService {
  Future<List<ComplexModel>> getComplexes({Map<String, dynamic>? query});
}

class ComplexesRemoteServiceImpl implements ComplexesRemoteService {
  static const Map<String, Type> _queryValidator = {
    'id': int,
    'complexName': String,
    'timeIni': String,
    'timeEnd': String,
    'locLongitude': double,
    'locLatitude': double,
    'createdAt': DateTime,
    'updatedAt': DateTime,
  };

  final AuthenticatedHttpClient _client;

  ComplexesRemoteServiceImpl({required AuthenticatedHttpClient client}) : _client = client;

  @override
  Future<List<ComplexModel>> getComplexes({Map<String, dynamic>? query}) async {
    Uri uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.complexesEndpoint}');

    if (query != null && query.isNotEmpty) {
      Map<String, String> queryParameters = {};
      query.forEach((key, value) {
        if (!_queryValidator.containsKey(key)) return;

        Type type = _queryValidator[key]!;
        String? valueString = Utilities.validateQueryValue(type: type, value: value);

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

        return data.map((e) => ComplexModel.fromJson(e)).toList();
      } else {
        final Map<String, dynamic> data;
        try {
          data = json.decode(utf8.decode(response.bodyBytes));
        } catch (e) {
          throw UnexpectedException(message: 'Error decoding response body: ${e.toString()}');
        }

        throw ServerException(
          message: data['message'] ?? 'Error getting complexes: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(message: 'Network error getting complexes: ${e.toString()}');
    }
  }
}
