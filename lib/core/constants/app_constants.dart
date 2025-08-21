import 'package:flutter/cupertino.dart';
import 'package:frontend/features/auth/presentation/screens/sign_up_sign_in_screen.dart';
import 'package:frontend/features/auth/presentation/screens/welcome_screen.dart';

class AppConstants {
  // TODO: Replace with your actual backend URL
  static const String baseUrl = 'http://192.168.1.35:3000'; // IP local del dispositivo
  // static const String baseUrl = 'http://10.0.2.2:3000'; // 10.0.2.2 es localhost para el emulador Android
  // static const String baseUrl = 'http://localhost:3000'; // Para iOS emulador o web

  static const String signUpEndpoint = '/auth/signup';
  static const String signInEndpoint = '/auth/signin';
  static const String refreshTokenEndpoint = '/auth/refresh';

  static final Map<String, Widget Function(BuildContext)> routes = {
    '/welcome': (context) => const WelcomeScreen(),
    '$signUpEndpoint/': (context) => const SignUpScreen(),
    '$signInEndpoint/': (context) => const SignInScreen(),
  };
}
