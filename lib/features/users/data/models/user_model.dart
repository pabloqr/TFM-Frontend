import 'dart:convert';

enum Role { superadmin, admin, client }

class UserModel {
  final int id;
  final Role role;
  final String name;
  final String? surname;
  final String mail;
  final int phonePrefix;
  final int phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.role,
    required this.name,
    this.surname,
    required this.mail,
    required this.phonePrefix,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Constructor factoría para crear un UserModel a partir de un objeto JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      role: Role.values.firstWhere((role) {
        final String name = role.name.toLowerCase();
        final String jsonName = (json['role'] as String).toLowerCase();
        return name == jsonName;
      }, orElse: () => Role.client),
      name: json['name'],
      surname: json['surname'],
      mail: json['mail'],
      phonePrefix: json['phonePrefix'] ?? json['phone_prefix'],
      phoneNumber: json['phoneNumber'] ?? json['phone_number'],
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['updated_at']),
    );
  }

  factory UserModel.fromJsonString(String jsonString) =>
      UserModel.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'role': role.name,
      'name': name,
      'mail': mail,
      'phonePrefix': phonePrefix,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

    if (surname != null) {
      data['surname'] = surname;
    }

    return data;
  }

  String toJsonString() => json.encode(toJson());
}
