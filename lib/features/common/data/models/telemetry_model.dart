import 'dart:convert';

class TelemetryModel {
  final double value;
  final DateTime? createdAt;

  TelemetryModel({required this.value, this.createdAt});

  factory TelemetryModel.fromJson(Map<String, dynamic> json) {
    return TelemetryModel(
      value: (json['value'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'value': value};

  String toJsonString() => json.encode(toJson());
}
