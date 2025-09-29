import 'dart:async';

import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:http/http.dart' as http;

class AuthenticatedHttpClient {
  final http.Client _client;
  final AuthRepository _authRepository;

  AuthenticatedHttpClient({required http.Client client, required AuthRepository authRepository})
    : _client = client,
      _authRepository = authRepository;

  //------------------------------------------------------------------------------------------------------------------//
  //------------------------------------------------------------------------------------------------------------------//

  Future<Map<String, String>> _buildHeaders(Map<String, String>? customHeaders) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?customHeaders,
    };

    final accessToken = await _authRepository.getValidAccessToken();
    accessToken.fold((failure) => null, (token) {
      headers['Authorization'] = 'Bearer $token';
    });

    return headers;
  }

  Future<http.Response> _authenticatedRequest(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Connection timeout', const Duration(seconds: 10)),
      );

      if (response.statusCode == 401) {
        final refreshTokenResult = await _authRepository.refreshToken();
        refreshTokenResult.fold((failure) => throw failure, (tokens) async {
          return await request().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Connection timeout', const Duration(seconds: 10)),
          );
        });
      }

      return response;
    } on TimeoutException catch (e) {
      throw NetworkException(message: 'Connection timeout during sign up: ${e.message}');
    } catch (e) {
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  //------------------------------------------------------------------------------------------------------------------//
  //------------------------------------------------------------------------------------------------------------------//

  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) async {
    return _authenticatedRequest(() async => _client.get(uri, headers: await _buildHeaders(headers)));
  }

  Future<http.Response> post(Uri uri, {Map<String, String>? headers, String? body}) async {
    return _authenticatedRequest(() async => _client.post(uri, headers: await _buildHeaders(headers), body: body));
  }

  Future<http.Response> put(Uri uri, {Map<String, String>? headers, String? body}) async {
    return _authenticatedRequest(() async => _client.put(uri, headers: await _buildHeaders(headers), body: body));
  }

  Future<http.Response> delete(Uri uri, {Map<String, String>? headers}) async {
    return _authenticatedRequest(() async => _client.delete(uri, headers: await _buildHeaders(headers)));
  }
}
