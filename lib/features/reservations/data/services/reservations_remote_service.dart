import 'dart:convert';

import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/data/services/authenticated_http_client.dart';
import 'package:frontend/data/services/utilities.dart';
import 'package:frontend/features/common/data/models/availability_status.dart';
import 'package:frontend/features/reservations/data/models/reservation_model.dart';

abstract class ReservationsRemoteService {
  Future<List<ReservationModel>> getReservations({Map<String, dynamic>? query});

  Future<ReservationModel> getReservation(int reservationId);

  Future<List<ReservationModel>> getUserReservations(int userId, {Map<String, dynamic>? query});

  Future<List<ReservationModel>> getComplexReservations(int complexId, {Map<String, dynamic>? query});

  Future<ReservationModel> createReservation(ReservationModel reservation);

  Future<ReservationModel> updateReservation(ReservationModel reservation);

  Future<void> deleteReservation(int reservationId);

  Future<ReservationModel> setReservationStatus(int reservationId, AvailabilityStatus status);
}

class ReservationsRemoteServiceImpl implements ReservationsRemoteService {
  static const Map<String, Type> _userQueryValidator = {
    'id': int,
    'complexId': int,
    'courtId': int,
    'dateIni': DateTime,
    'dateEnd': DateTime,
    'status': AvailabilityStatus,
    'reservationStatus': ReservationStatus,
    'timeFilter': TimeFilter,
    'createdAt': DateTime,
    'updatedAt': DateTime,
  };

  final AuthenticatedHttpClient _client;

  ReservationsRemoteServiceImpl({required AuthenticatedHttpClient client}) : _client = client;

  @override
  Future<List<ReservationModel>> getReservations({Map<String, dynamic>? query}) async {
    // TODO: implement getReservations
    throw UnimplementedError();
  }

  @override
  Future<ReservationModel> getReservation(int reservationId) async {
    Uri uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.reservationsUDEndpoint(reservationId.toString())}');

    try {
      final response = await _client.get(uri);

      final Map<String, dynamic> data;
      try {
        data = json.decode(utf8.decode(response.bodyBytes));
      } catch (e) {
        throw UnexpectedException(message: 'Error decoding response body: ${e.toString()}');
      }

      if (response.statusCode == 200) {
        return ReservationModel.fromJson(data);
      } else {
        throw ServerException(
          message: data['message'] ?? 'Error getting reservation: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(message: 'Network error getting reservation: ${e.toString()}');
    }
  }

  @override
  Future<List<ReservationModel>> getUserReservations(int userId, {Map<String, dynamic>? query}) async {
    Uri uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.reservationsUsersEndpoint(userId.toString())}');

    if (query != null && query.isNotEmpty) {
      Map<String, String> queryParameters = {};
      query.forEach((key, value) {
        if (!_userQueryValidator.containsKey(key)) return;

        Type type = _userQueryValidator[key]!;
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

        return data.map((e) => ReservationModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        final Map<String, dynamic> data;
        try {
          data = json.decode(utf8.decode(response.bodyBytes));
        } catch (e) {
          throw UnexpectedException(message: 'Error decoding response body: ${e.toString()}');
        }

        throw ServerException(
          message: data['message'] ?? 'Error getting user reservations: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(message: 'Network error getting user reservations: ${e.toString()}');
    }
  }

  @override
  Future<List<ReservationModel>> getComplexReservations(int complexId, {Map<String, dynamic>? query}) async {
    Uri uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.reservationsComplexesCREndpoint(complexId.toString())}');

    if (query != null && query.isNotEmpty) {
      Map<String, String> queryParameters = {};
      query.forEach((key, value) {
        if (!_userQueryValidator.containsKey(key)) return;

        Type type = _userQueryValidator[key]!;
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

        return data.map((e) => ReservationModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        final Map<String, dynamic> data;
        try {
          data = json.decode(utf8.decode(response.bodyBytes));
        } catch (e) {
          throw UnexpectedException(message: 'Error decoding response body: ${e.toString()}');
        }

        throw ServerException(
          message: data['message'] ?? 'Error getting complex reservations: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(message: 'Network error getting complex reservations: ${e.toString()}');
    }
  }

  @override
  Future<ReservationModel> createReservation(ReservationModel reservation) async {
    // TODO: implement createReservation
    throw UnimplementedError();
  }

  @override
  Future<ReservationModel> updateReservation(ReservationModel reservation) async {
    // TODO: implement updateReservation
    throw UnimplementedError();
  }

  @override
  Future<void> deleteReservation(int reservationId) async {
    // TODO: implement deleteReservation
    throw UnimplementedError();
  }

  @override
  Future<ReservationModel> setReservationStatus(int reservationId, AvailabilityStatus status) async {
    // TODO: implement setReservationStatus
    throw UnimplementedError();
  }
}
