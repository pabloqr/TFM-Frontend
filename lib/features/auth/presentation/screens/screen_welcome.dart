import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Se determina el brillo de los iconos de la barra de estado
    // Si el color primario es oscuro, los iconos deben ser claros
    final Brightness statusBarIconBrightness =
        ThemeData.estimateBrightnessForColor(colorScheme.primary) ==
            Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colorScheme.primary,
        statusBarIconBrightness: statusBarIconBrightness,
        statusBarBrightness: statusBarIconBrightness,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.primary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Let’s play some sport!',
                        textAlign: TextAlign.start,
                        style: textTheme.displayMedium?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'What do you want to do?',
                        textAlign: TextAlign.start,
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: BorderSide(color: colorScheme.onPrimary),
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      child: Text('Sign in'),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: colorScheme.onPrimary,
                        foregroundColor: colorScheme.primary,
                      ),
                      child: Text('Sign up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
