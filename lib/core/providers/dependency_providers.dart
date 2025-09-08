import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/data/providers/settings_provider.dart'; // AÑADIDO
import 'package:frontend/data/providers/auth_provider.dart';
import 'package:frontend/data/providers/complexes_provider.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/complexes_repository.dart';
import 'package:frontend/data/services/authenticated_http_client.dart';
import 'package:frontend/domain/usecases/auth_use_cases.dart';
import 'package:frontend/domain/usecases/complexes_use_cases.dart';
import 'package:frontend/features/auth/data/services/auth_local_service.dart';
import 'package:frontend/features/auth/data/services/auth_remote_service.dart';
import 'package:frontend/features/common/presentation/widgets/time_range_selector.dart';
import 'package:frontend/features/complexes/data/services/complexes_remote_service.dart';
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

    Provider<FlutterSecureStorage>(create: (_) => const FlutterSecureStorage()),

    FutureProvider<SharedPreferences?>(create: (_) => SharedPreferences.getInstance(), initialData: null),

    // ---------------------------------------------------------------------------------------------------------------//
    // SERVICES LEVEL 1 (No dependencies on other custom services)
    // ---------------------------------------------------------------------------------------------------------------//
    ProxyProvider<http.Client, AuthRemoteService>(
      update: (context, client, previousAuthRemoteService) => AuthRemoteServiceImpl(client: client),
    ),

    ProxyProvider2<FlutterSecureStorage, SharedPreferences?, AuthLocalService?>(
      update: (context, secureStorage, sharedPreferences, previousAuthLocalService) {
        return sharedPreferences != null
            ? AuthLocalServiceImpl(secureStorage: secureStorage, sharedPreferences: sharedPreferences)
            : null;
      },
    ),

    // ---------------------------------------------------------------------------------------------------------------//
    // REPOSITORIES LEVEL 1 (Depend on services from level 1)
    // ---------------------------------------------------------------------------------------------------------------//
    ProxyProvider2<AuthRemoteService, AuthLocalService?, AuthRepository?>(
      update: (context, remoteService, localService, previousAuthRepository) {
        return localService != null
            ? AuthRepositoryImpl(remoteService: remoteService, localService: localService)
            : null;
      },
    ),

    // ---------------------------------------------------------------------------------------------------------------//
    // SERVICES LEVEL 2 (Depend on repositories)
    // ---------------------------------------------------------------------------------------------------------------//
    ProxyProvider2<http.Client, AuthRepository?, AuthenticatedHttpClient?>(
      update: (context, client, authRepository, previousAuthenticatedHttpClient) {
        return authRepository != null ? AuthenticatedHttpClient(client: client, authRepository: authRepository) : null;
      },
    ),

    ProxyProvider<AuthenticatedHttpClient?, ComplexesRemoteService?>(
      update: (context, authenticatedClient, previousComplexesRemoteService) {
        return authenticatedClient != null ? ComplexesRemoteServiceImpl(client: authenticatedClient) : null;
      },
    ),

    // ---------------------------------------------------------------------------------------------------------------//
    // REPOSITORIES LEVEL 2 (Depend on services from level 2)
    // ---------------------------------------------------------------------------------------------------------------//
    ProxyProvider<ComplexesRemoteService?, ComplexesRepository?>(
      update: (context, remoteService, previousComplexesRepository) {
        return remoteService != null ? ComplexesRepositoryImpl(remoteService: remoteService) : null;
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

    ProxyProvider<ComplexesRepository?, ComplexesUseCases?>(
      update: (context, repository, previousComplexesUseCases) {
        return repository != null ? ComplexesUseCases(repository: repository) : null;
      },
    ),

    // ---------------------------------------------------------------------------------------------------------------//
    // PROVIDERS (ChangeNotifiers)
    // ---------------------------------------------------------------------------------------------------------------//
    ChangeNotifierProxyProvider<SharedPreferences?, SettingsProvider?>(
      create: (_) => null,
      update: (context, sharedPreferences, previousSettingsProvider) {
        if (sharedPreferences == null || previousSettingsProvider != null) {
          return previousSettingsProvider;
        }

        return SettingsProvider(sharedPreferences: sharedPreferences)..initialize();
      },
    ),

    ChangeNotifierProxyProvider<AuthUseCases?, AuthProvider?>(
      create: (context) => null,
      update: (context, authUseCases, previousAuthProvider) {
        // Si no existe el caso de uso pero sí existe un AuthProvider, no crear uno nuevo
        if (authUseCases == null || previousAuthProvider != null) {
          return previousAuthProvider; // Mantener el anterior si existe
        }

        return AuthProvider(authUseCases: authUseCases)..initialize();
      },
    ),

    ChangeNotifierProxyProvider<ComplexesUseCases?, ComplexesProvider?>(
      create: (context) => null,
      update: (context, complexesUseCases, previousComplexesProvider) {
        // Si no existe el caso de uso pero sí existe un ComplexesProvider, no crear uno nuevo
        if (complexesUseCases == null || previousComplexesProvider != null) {
          return previousComplexesProvider;
        }

        return ComplexesProvider(complexesUseCases: complexesUseCases);
      },
    ),

    ChangeNotifierProvider<TimeRangeController>(create: (_) => TimeRangeController()),
  ];
}
