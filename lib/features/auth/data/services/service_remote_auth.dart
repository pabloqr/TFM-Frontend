import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/features/auth/data/models/model_sign_up_request.dart';
import 'package:frontend/features/auth/data/models/model_auth_response.dart';

abstract class AuthRemoteService {
  Future<AuthResponseModel> signUp(SignUpRequestModel request);
}

class AuthRemoteServiceImpl implements AuthRemoteService {
  final http.Client _client;

  AuthRemoteServiceImpl({required http.Client client}) : _client = client;

  @override
  Future<AuthResponseModel> signUp(SignUpRequestModel request) async {
    final Uri uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.signUpEndpoint}');

    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: request.toJsonString(),
      );

      final Map<String, dynamic> data;
      try {
        data = json.decode(utf8.decode(response.bodyBytes));
      } catch (e) {
        throw UnexpectedException(message: 'Error decoding response body: ${e.toString()}');
      }

      if (response.statusCode == 201) {
        return AuthResponseModel.fromJson(data);
      } else {
        throw ServerException(
          message: data['message'] ?? 'Error signing up: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(message: 'Network error signing up: ${e.toString()}');
    }
  }
}
