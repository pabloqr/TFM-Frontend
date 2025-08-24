import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/data/providers/auth_provider.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/services/authenticated_http_client.dart';
import 'package:frontend/domain/usecases/auth_use_cases.dart';
import 'package:frontend/features/auth/data/services/auth_local_service.dart';
import 'package:frontend/features/auth/data/services/auth_remote_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<SingleChildWidget> get appProviders {
  return [
    // ---------------------------------------------------------------------------------------------------------------//
    // BASE DEPENDENCIES
    // ---------------------------------------------------------------------------------------------------------------//
    Provider<http.Client>(create: (_) => http.Client(), dispose: (_, client) => client.close()),

    ProxyProvider2<http.Client, AuthRepository?, AuthenticatedHttpClient?>(
      update: (context, client, authRepository, previousAuthenticatedHttpClient) {
        return authRepository != null ? AuthenticatedHttpClient(client: client, authRepository: authRepository) : null;
      },
    ),

    Provider<FlutterSecureStorage>(create: (_) => const FlutterSecureStorage()),

    FutureProvider<SharedPreferences?>(create: (_) => SharedPreferences.getInstance(), initialData: null),

    // ---------------------------------------------------------------------------------------------------------------//
    // SERVICES
    // ---------------------------------------------------------------------------------------------------------------//
    ProxyProvider2<FlutterSecureStorage, SharedPreferences?, AuthLocalService?>(
      update: (context, secureStorage, sharedPreferences, previousAuthLocalService) {
        return sharedPreferences != null
            ? AuthLocalServiceImpl(secureStorage: secureStorage, sharedPreferences: sharedPreferences)
            : null;
      },
    ),

    ProxyProvider<http.Client, AuthRemoteService>(
      update: (context, client, previousAuthRemoteService) => AuthRemoteServiceImpl(client: client),
    ),

    // ---------------------------------------------------------------------------------------------------------------//
    // REPOSITORIES
    // ---------------------------------------------------------------------------------------------------------------//
    ProxyProvider2<AuthRemoteService?, AuthLocalService?, AuthRepository?>(
      update: (context, remoteService, localService, previousAuthRepository) {
        // Check if both services are available before creating the repository
        return remoteService != null && localService != null
            ? AuthRepositoryImpl(remoteService: remoteService, localService: localService)
            : null;
      },
    ),

    // ---------------------------------------------------------------------------------------------------------------//
    // USE CASES
    // ---------------------------------------------------------------------------------------------------------------//
    ProxyProvider<AuthRepository?, AuthUseCases?>(
      update: (context, repository, previousAuthUseCases) {
        return repository != null ? AuthUseCases(repository: repository) : null;
      },
    ),

    // ---------------------------------------------------------------------------------------------------------------//
    // PROVIDERS
    // ---------------------------------------------------------------------------------------------------------------//
    ChangeNotifierProxyProvider<AuthUseCases?, AuthProvider?>(
      create: (context) => null,
      update: (context, authUseCases, previousAuthProvider) {
        if (authUseCases == null) return null;
        return AuthProvider(authUseCases: authUseCases)..initialize();
      },
    ),
  ];
}
