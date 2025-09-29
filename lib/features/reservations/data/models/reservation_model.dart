import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/features/common/data/models/availability_status.dart';
import 'package:frontend/features/common/presentation/widgets/medium_chip.dart';
import 'package:frontend/features/common/presentation/widgets/small_chip.dart';

enum ReservationStatus { scheduled, weather, completed, cancelled }

extension ReservationStatusExtension on ReservationStatus {
  Widget get smallStatusChip {
    switch (this) {
      case ReservationStatus.scheduled:
        return SmallChip.neutralSurface(label: 'Scheduled');
      case ReservationStatus.weather:
        return SmallChip.alert(label: 'Weather');
      case ReservationStatus.completed:
        return SmallChip.success(label: 'Completed');
      case ReservationStatus.cancelled:
        return SmallChip.error(label: 'Cancelled');
    }
  }

  Widget get mediumStatusChip {
    switch (this) {
      case ReservationStatus.scheduled:
        return MediumChip.neutralSurface(label: 'Scheduled');
      case ReservationStatus.weather:
        return MediumChip.alert(label: 'Weather');
      case ReservationStatus.completed:
        return MediumChip.success(label: 'Completed');
      case ReservationStatus.cancelled:
        return MediumChip.error(label: 'Cancelled');
    }
  }
}

enum TimeFilter { all, past, upcoming }

class ReservationModel {
  int id;
  int userId;
  int complexId;
  int courtId;
  DateTime dateIni;
  DateTime dateEnd;
  AvailabilityStatus status;
  ReservationStatus reservationStatus;
  TimeFilter timeFilter;
  DateTime createdAt;
  DateTime updatedAt;

  ReservationModel({
    required this.id,
    required this.userId,
    required this.complexId,
    required this.courtId,
    required this.dateIni,
    required this.dateEnd,
    required this.status,
    required this.reservationStatus,
    required this.timeFilter,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      complexId: json['complexId'] as int,
      courtId: json['courtId'] as int,
      dateIni: DateTime.parse(json['dateIni'] as String),
      dateEnd: DateTime.parse(json['dateEnd'] as String),
      status: AvailabilityStatus.values.firstWhere((status) {
        final String name = status.name.toLowerCase();
        final String jsonName = (json['status'] as String).toLowerCase();
        return name == jsonName;
      }),
      reservationStatus: ReservationStatus.values.firstWhere((status) {
        final String name = status.name.toLowerCase();
        final String jsonName = (json['reservationStatus'] as String).toLowerCase();
        return name == jsonName;
      }),
      timeFilter: TimeFilter.values.firstWhere((filter) {
        final String name = filter.name.toLowerCase();
        final String jsonName = (json['timeFilter'] as String).toLowerCase();
        return name == jsonName;
      }),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  factory ReservationModel.fromJsonString(String jsonString) =>
      ReservationModel.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'userId': userId,
      'complexId': complexId,
      'courtId': courtId,
      'dateIni': dateIni.toIso8601String(),
      'dateEnd': dateEnd.toIso8601String(),
      'status': status.name,
      'reservationStatus': reservationStatus.name,
      'timeFilter': timeFilter.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

    return data;
  }

  String toJsonString() => json.encode(toJson());

  @override
  String toString() {
    return 'ReservationModel(id: $id, userId: $userId, complexId: $complexId, courtId: $courtId, dateIni: $dateIni, dateEnd: $dateEnd, status: $status, reservationStatus: $reservationStatus, timeFilter: $timeFilter, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
