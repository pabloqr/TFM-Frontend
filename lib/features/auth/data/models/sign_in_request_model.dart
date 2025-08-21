import 'dart:convert';

class SignInRequestModel {
  final String mail;
  final String password;

  SignInRequestModel({required this.mail, required this.password});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'mail': mail, 'password': password};
  }

  String toJsonString() => json.encode(toJson());
}
