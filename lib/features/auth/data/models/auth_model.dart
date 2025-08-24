import '../../../users/data/models/user_model.dart';

class AuthModel {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  AuthModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      user: UserModel.fromJson(json['user']),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {...user.toJson(), 'accessToken': accessToken, 'refreshToken': refreshToken, 'expiresIn': expiresIn};
  }
}
