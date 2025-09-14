import 'dart:convert';

import 'package:frontend/features/common/data/models/availability_status.dart';
import 'package:frontend/features/devices/data/models/device_model.dart';

class TelemetryModel {
  final double value;
  final DeviceType? type;
  final DateTime? createdAt;

  TelemetryModel({required this.value, this.type, this.createdAt});

  factory TelemetryModel.fromJson(Map<String, dynamic> json) {
    return TelemetryModel(
      value: (json['value'] as num).toDouble(),
      type: DeviceType.values.firstWhere((type) {
        final String name = type.name.toLowerCase();
        final String jsonName = (json['type'] as String).toLowerCase();
        return name == jsonName;
      }, orElse: () => DeviceType.presence),
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'value': value};

  String toJsonString() => json.encode(toJson());

  AvailabilityStatus toAvailabilityStatus() {
    return value == 0.0 ? AvailabilityStatus.empty : AvailabilityStatus.occupied;
  }
}
