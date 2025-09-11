import 'package:frontend/features/courts/data/models/court_status_model.dart';
import 'package:frontend/features/courts/data/models/sport_enum.dart';

class CourtModel {
  final int id;
  final Sport sport;
  final String name;
  final String description;
  final int maxPeople;
  final CourtStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourtModel({
    required this.id,
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
