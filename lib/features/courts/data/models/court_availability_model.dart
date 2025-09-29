class CourtAvailabilitySlot {
  final DateTime dateIni;
  final DateTime dateEnd;
  final bool available;

  CourtAvailabilitySlot({required this.dateIni, required this.dateEnd, required this.available});
}

class CourtAvailabilityModel {
  final int id;
  final int complexId;
  final List<CourtAvailabilitySlot> availability;

  CourtAvailabilityModel({required this.id, required this.complexId, required this.availability});

  factory CourtAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return CourtAvailabilityModel(
      id: json['id'] as int,
      complexId: json['complexId'] as int,
      availability: (json['availability'] as List<dynamic>).map((e) {
        final Map<String, dynamic> slot = e as Map<String, dynamic>;
        return CourtAvailabilitySlot(
          dateIni: DateTime.parse(slot['dateIni'] as String),
          dateEnd: DateTime.parse(slot['dateEnd'] as String),
          available: slot['available'] as bool,
        );
      }).toList(),
    );
  }
}
