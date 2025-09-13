enum DeviceType { presence, rain }

enum DeviceStatus { normal, off, battery, error }

class DeviceModel {
  final int id;
  final int complexId;
  final DeviceType type;
  final DeviceStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeviceModel({
    required this.id,
    required this.complexId,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as int,
      complexId: json['complexId'] as int,
      type: DeviceType.values.firstWhere((sport) {
        final String name = sport.name.toLowerCase();
        final String jsonName = (json['type'] as String).toLowerCase();
        return name == jsonName;
      }, orElse: () => DeviceType.presence),
      status: DeviceStatus.values.firstWhere((status) {
        final String name = status.name.toLowerCase();
        final String jsonName = (json['status'] as String).toLowerCase();
        return name == jsonName;
      }, orElse: () => DeviceStatus.normal),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
