import 'package:flutter/material.dart';
import 'package:frontend/features/common/presentation/widgets/medium_chip.dart';
import 'package:frontend/features/common/presentation/widgets/small_chip.dart';
import 'package:frontend/features/courts/data/models/sport_enum.dart';

enum CourtStatus { open, maintenance, blocked, weather }

extension CourtStatusExtension on CourtStatus {
  Widget get smallStatusChip {
    switch (this) {
      case CourtStatus.open:
        return SmallChip.success(label: 'Open');
      case CourtStatus.weather:
        return SmallChip.alert(label: 'Weather');
      case CourtStatus.maintenance:
        return SmallChip.error(label: 'Maintenance');
      case CourtStatus.blocked:
        return SmallChip.error(label: 'Closed');
    }
  }

  Widget get mediumStatusChip {
    switch (this) {
      case CourtStatus.open:
        return MediumChip.success(label: 'Open');
      case CourtStatus.weather:
        return MediumChip.alert(label: 'Weather');
      case CourtStatus.maintenance:
        return MediumChip.error(label: 'Maintenance');
      case CourtStatus.blocked:
        return MediumChip.error(label: 'Closed');
    }
  }
}

class CourtModel {
  final int id;
  final int complexId;
  final Sport sport;
  final String name;
  final String description;
  final int maxPeople;
  final CourtStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourtModel({
    required this.id,
    required this.complexId,
    required this.sport,
    required this.name,
    required this.description,
    required this.maxPeople,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourtModel.fromJson(Map<String, dynamic> json) {
    return CourtModel(
      id: json['id'] as int,
      complexId: json['complexId'] as int,
      sport: Sport.values.firstWhere((sport) {
        final String name = sport.name.toLowerCase();
        final String jsonName = (json['sport'] as String).toLowerCase();
        return name == jsonName;
      }, orElse: () => Sport.tennis),
      name: json['name'] as String,
      description: json['description'] as String,
      maxPeople: json['maxPeople'] as int,
      status: CourtStatus.values.firstWhere((status) {
        final String name = status.name.toLowerCase();
        final String jsonName = (json['status'] as String).toLowerCase();
        return name == jsonName;
      }, orElse: () => CourtStatus.open),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
