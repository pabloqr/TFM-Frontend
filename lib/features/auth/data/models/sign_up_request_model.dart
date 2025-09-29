import 'dart:convert';

class SignUpRequestModel {
  final String name;
  final String? surname;
  final String mail;
  final int phonePrefix;
  final int phoneNumber;
  final String password;

  SignUpRequestModel({
    required this.name,
    this.surname,
    required this.phonePrefix,
    required this.phoneNumber,
    required this.mail,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    // Se construye el objeto JSON
    final Map<String, dynamic> data = <String, dynamic>{
      'name': name,
      'mail': mail,
      'phonePrefix': phonePrefix,
      'phoneNumber': phoneNumber,
      'password': password,
    };

    // Si el usuario proporciona un apellido, se agrega al JSON
    if (surname != null) {
      data['surname'] = surname;
    }

    return data;
  }

  String toJsonString() => json.encode(toJson());
}
