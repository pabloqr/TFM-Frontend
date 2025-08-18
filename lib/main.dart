import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/screens/screen_signup_signin.dart';

import 'core/constants/theme.dart';
import 'features/auth/presentation/screens/screen_welcome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theme = MaterialTheme();

    return MaterialApp(
      title: 'TFM',
      theme: theme.light(),
      // darkTheme: theme.dark(), // Puedes descomentar esto si tienes un tema oscuro
      home: const SignUpScreen(),
    );
  }
}
