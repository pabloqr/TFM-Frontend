class ComplexModel {
  final int id;
  final String complexName;
  final String timeIni;
  final String timeEnd;
  final double? locLongitude;
  final double? locLatitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  ComplexModel({
    required this.id,
    required this.complexName,
    required this.timeIni,
    required this.timeEnd,
    required this.locLongitude,
    required this.locLatitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ComplexModel.fromJson(Map<String, dynamic> json) {
    return ComplexModel(
      id: json['id'] as int,
      complexName: json['complexName'] as String,
      timeIni: json['timeIni'] as String,
      timeEnd: json['timeEnd'] as String,
      locLongitude: json['locLongitude'] as double?,
      locLatitude: json['locLatitude'] as double?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
