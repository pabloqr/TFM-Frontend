import 'package:flutter/material.dart';
import 'package:frontend/core/constants/theme.dart';
import 'package:frontend/core/providers/dependency_providers.dart';
import 'package:frontend/features/auth/presentation/screens/screen_signup_signin.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: appProviders, child: const MyApp()));
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
      // darkTheme: theme.dark(), // TODO: descomentar al finalizar
      home: Consumer<SharedPreferences?>(
        builder: (context, sharedPreferences, child) {
          if (sharedPreferences == null) {
            final colorScheme = Theme.of(context).colorScheme;

            return Container(
              color: colorScheme.surface,
              child: Center(child: CircularProgressIndicator()),
            );
          }


          return const SignUpScreen();
        },
      ),
    );
  }
}
