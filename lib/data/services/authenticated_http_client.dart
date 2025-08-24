import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:http/http.dart' as http;

class AuthenticatedHttpClient {
  final http.Client _client;
  final String _baseUrl = AppConstants.baseUrl;
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
      final response = await request();

      if (response.statusCode == 401) {
        final refreshTokenResult = await _authRepository.refreshToken();
        refreshTokenResult.fold((failure) => throw failure, (tokens) async {
          return await request();
        });
      }

      return response;
    } catch (e) {
      throw NetworkException(message: 'Network error: ${e.toString()}');
    }
  }

  //------------------------------------------------------------------------------------------------------------------//
  //------------------------------------------------------------------------------------------------------------------//

  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    return _authenticatedRequest(
      () async => _client.get(Uri.parse('$_baseUrl$endpoint'), headers: await _buildHeaders(headers)),
    );
  }

  Future<http.Response> post(String endpoint, {Map<String, String>? headers, String? body}) async {
    return _authenticatedRequest(
      () async => _client.post(Uri.parse('$_baseUrl$endpoint'), headers: await _buildHeaders(headers), body: body),
    );
  }

  Future<http.Response> put(String endpoint, {Map<String, String>? headers, String? body}) async {
    return _authenticatedRequest(
      () async => _client.put(Uri.parse('$_baseUrl$endpoint'), headers: await _buildHeaders(headers), body: body),
    );
  }

  Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    return _authenticatedRequest(
      () async => _client.delete(Uri.parse('$_baseUrl$endpoint'), headers: await _buildHeaders(headers)),
    );
  }
}
