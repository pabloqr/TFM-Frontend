import 'package:flutter/material.dart';
import 'package:frontend/data/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AuthGuardWidget extends StatelessWidget {
  final Widget child;
  final Widget loginScreen;

  const AuthGuardWidget({super.key, required this.child, required this.loginScreen});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        switch (authProvider.state) {
          case AuthState.initial:
          case AuthState.loading:
            final colorScheme = Theme.of(context).colorScheme;

            return Scaffold(
              body: Container(
                color: colorScheme.surface,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          case AuthState.authenticated:
            return child;
          case AuthState.unauthenticated:
            return loginScreen;
        }
      },
    );
  }
}
