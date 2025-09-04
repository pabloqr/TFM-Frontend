import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/core/constants/theme.dart';
import 'package:frontend/core/providers/dependency_providers.dart';
import 'package:frontend/features/auth/presentation/screens/welcome_screen.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_guard.dart';
import 'package:frontend/features/users/presentation/screens/admin_home_screen.dart';
import 'package:frontend/features/users/presentation/screens/client_home_screen.dart';
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

            return Scaffold(
              body: Container(
                color: colorScheme.surface,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          return const AppInitializer();
        },
      ),
      routes: AppConstants.routes,
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  Widget build(BuildContext context) {
    return AuthGuard(loginScreen: WelcomeScreen(), clientApp: ClientHomeScreen(), adminApp: AdminHomeScreen());
  }
}
