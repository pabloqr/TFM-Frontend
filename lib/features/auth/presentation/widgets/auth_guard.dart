import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/providers/auth_provider.dart';
import 'package:frontend/domain/usecases/auth_use_cases.dart';
import 'package:frontend/features/users/data/models/user_model.dart';
import 'package:provider/provider.dart';

class AuthGuard extends StatelessWidget {
  final Widget loginScreen;
  final Widget Function(int) clientAppBuilder;
  final Widget Function(int) adminAppBuilder;

  const AuthGuard({super.key, required this.loginScreen, required this.clientAppBuilder, required this.adminAppBuilder});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        switch (authProvider.state) {
          case AuthState.initial:
          case AuthState.loading:
            return _buildLoadingScreen(context);
          case AuthState.unauthenticated:
            return loginScreen;
          case AuthState.authenticated:
            // Get auth use cases and verify if it's valid
            final authUseCases = context.read<AuthUseCases?>();
            if (authUseCases == null) return loginScreen;

            // User is authenticated, now determine role
            return FutureBuilder<Either<Failure, UserModel>>(
              future: authUseCases.getAuthenticatedUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingScreen(context);
                } else if (snapshot.hasError || !snapshot.hasData) {
                  // Handle error or no data case, potentially redirect to login
                  return loginScreen;
                }

                final eitherResult = snapshot.data!;
                return eitherResult.fold(
                  (failure) {
                    // Handle failure
                    return loginScreen;
                  },
                  (user) {
                    Navigator.of(context).popUntil((route) => route.isFirst);

                    // Successfully fetched user, now check role and return appropriate screen
                    switch (user.role) {
                      case Role.client:
                        return clientAppBuilder(user.id);
                      case Role.admin:
                      case Role.superadmin:
                        return adminAppBuilder(1);
                    }
                  },
                );
              },
            );
        }
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: colorScheme.surface,
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
