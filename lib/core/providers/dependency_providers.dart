import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/data/providers/complex_provider.dart';
import 'package:frontend/data/providers/court_provider.dart';
import 'package:frontend/data/providers/courts_list_provider.dart';
import 'package:frontend/data/providers/device_courts_provider.dart';
import 'package:frontend/data/providers/devices_list_provider.dart';
import 'package:frontend/data/providers/reservation_provider.dart';
import 'package:frontend/data/providers/reservations_list_provider.dart';
import 'package:frontend/data/providers/settings_provider.dart'; // AÑADIDO
import 'package:frontend/data/providers/auth_provider.dart';
import 'package:frontend/data/providers/complexes_list_provider.dart';
import 'package:frontend/data/providers/telemetry_provider.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/complexes_repository.dart';
import 'package:frontend/data/repositories/courts_repository.dart';
import 'package:frontend/data/repositories/devices_repository.dart';
import 'package:frontend/data/repositories/reservations_repository.dart';
import 'package:frontend/data/services/authenticated_http_client.dart';
import 'package:frontend/domain/usecases/auth_use_cases.dart';
import 'package:frontend/domain/usecases/complexes_use_cases.dart';
import 'package:frontend/domain/usecases/courts_use_cases.dart';
import 'package:frontend/domain/usecases/devices_use_cases.dart';
import 'package:frontend/domain/usecases/reservations_use_cases.dart';
import 'package:frontend/features/auth/data/services/auth_local_service.dart';
import 'package:frontend/features/auth/data/services/auth_remote_service.dart';
import 'package:frontend/features/common/presentation/widgets/time_range_selector.dart';
import 'package:frontend/features/complexes/data/services/complexes_remote_service.dart';
import 'package:frontend/features/courts/data/services/courts_remote_service.dart';
import 'package:frontend/features/devices/data/services/devices_remote_service.dart';
import 'package:frontend/features/reservations/data/services/reservations_remote_service.dart';
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
      update: (context, authenticatedClient, previousRemoteService) {
        return authenticatedClient != null ? ComplexesRemoteServiceImpl(client: authenticatedClient) : null;
      },
    ),

    ProxyProvider<AuthenticatedHttpClient?, CourtsRemoteService?>(
      update: (context, authenticatedClient, previousRemoteService) {
        return authenticatedClient != null ? CourtsRemoteServiceImpl(client: authenticatedClient) : null;
      },
    ),

    ProxyProvider<AuthenticatedHttpClient?, DevicesRemoteService?>(
      update: (context, authenticatedClient, previousRemoteService) {
        return authenticatedClient != null ? DevicesRemoteServiceImpl(client: authenticatedClient) : null;
      },
    ),

    ProxyProvider<AuthenticatedHttpClient?, ReservationsRemoteService?>(
      update: (context, authenticatedClient, previousRemoteService) {
        return authenticatedClient != null ? ReservationsRemoteServiceImpl(client: authenticatedClient) : null;
      },
    ),

    // ---------------------------------------------------------------------------------------------------------------//
    // REPOSITORIES LEVEL 2 (Depend on services from level 2)
    // ---------------------------------------------------------------------------------------------------------------//
    ProxyProvider<ComplexesRemoteService?, ComplexesRepository?>(
      update: (context, remoteService, previousRepository) {
        return remoteService != null ? ComplexesRepositoryImpl(remoteService: remoteService) : null;
      },
    ),

    ProxyProvider<CourtsRemoteService?, CourtsRepository?>(
      update: (context, remoteService, previousRepository) {
        return remoteService != null ? CourtsRepositoryImpl(remoteService: remoteService) : null;
      },
    ),

    ProxyProvider<DevicesRemoteService?, DevicesRepository?>(
      update: (context, remoteService, previousRepository) {
        return remoteService != null ? DevicesRepositoryImpl(remoteService: remoteService) : null;
      },
    ),

    ProxyProvider<ReservationsRemoteService?, ReservationsRepository?>(
      update: (context, remoteService, previousRepository) {
        return remoteService != null ? ReservationsRepositoryImpl(remoteService: remoteService) : null;
      },
    ),

    // ---------------------------------------------------------------------------------------------------------------//
    // USE CASES
    // ---------------------------------------------------------------------------------------------------------------//
    ProxyProvider<AuthRepository?, AuthUseCases?>(
      update: (context, repository, previousUseCases) {
        return repository != null ? AuthUseCases(repository: repository) : null;
      },
    ),

    ProxyProvider<ComplexesRepository?, ComplexesUseCases?>(
      update: (context, repository, previousUseCases) {
        return repository != null ? ComplexesUseCases(repository: repository) : null;
      },
    ),

    ProxyProvider<CourtsRepository?, CourtsUseCases?>(
      update: (context, repository, previousUseCases) {
        return repository != null ? CourtsUseCases(repository: repository) : null;
      },
    ),

    ProxyProvider<DevicesRepository?, DevicesUseCases?>(
      update: (context, repository, previousUseCases) {
        return repository != null ? DevicesUseCases(repository: repository) : null;
      },
    ),

    ProxyProvider<ReservationsRepository?, ReservationsUseCases?>(
      update: (context, repository, previousUseCases) {
        return repository != null ? ReservationsUseCases(repository: repository) : null;
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
      update: (context, useCases, previousProvider) {
        // Si no existe el caso de uso pero sí existe un AuthProvider, no crear uno nuevo
        if (useCases == null || previousProvider != null) {
          return previousProvider; // Mantener el anterior si existe
        }

        return AuthProvider(authUseCases: useCases)..initialize();
      },
    ),

    ChangeNotifierProxyProvider<ComplexesUseCases?, ComplexesListProvider?>(
      create: (context) => null,
      update: (context, useCases, previousProvider) {
        // Si no existe el caso de uso pero sí existe un ComplexesProvider, no crear uno nuevo
        if (useCases == null || previousProvider != null) {
          return previousProvider;
        }

        return ComplexesListProvider(complexesUseCases: useCases);
      },
    ),

    ChangeNotifierProxyProvider<ComplexesUseCases?, ComplexProvider?>(
      create: (context) => null,
      update: (context, useCases, previousProvider) {
        // Si no existe el caso de uso pero sí existe un ComplexesProvider, no crear uno nuevo
        if (useCases == null || previousProvider != null) {
          return previousProvider;
        }

        return ComplexProvider(complexesUseCases: useCases);
      },
    ),

    ChangeNotifierProxyProvider<CourtsUseCases?, CourtsListProvider?>(
      create: (context) => null,
      update: (context, useCases, previousProvider) {
        // Si no existe el caso de uso pero sí existe un CourtsProvider, no crear uno nuevo
        if (useCases == null || previousProvider != null) {
          return previousProvider;
        }

        return CourtsListProvider(courtsUseCases: useCases);
      },
    ),

    ChangeNotifierProxyProvider<CourtsUseCases?, CourtProvider?>(
      create: (context) => null,
      update: (context, useCases, previousProvider) {
        // Si no existe el caso de uso pero sí existe un CourtsProvider, no crear uno nuevo
        if (useCases == null || previousProvider != null) {
          return previousProvider;
        }

        return CourtProvider(courtsUseCases: useCases);
      },
    ),

    ChangeNotifierProxyProvider2<DevicesUseCases?, CourtsUseCases?, DevicesListProvider?>(
      create: (context) => null,
      update: (context, useCases1, useCases2, previousProvider) {
        // Si no existe el caso de uso pero sí existe un CourtsProvider, no crear uno nuevo
        if (useCases1 == null || useCases2 == null || previousProvider != null) {
          return previousProvider;
        }

        return DevicesListProvider(devicesUseCases: useCases1, courtsUseCases: useCases2);
      },
    ),

    ChangeNotifierProxyProvider<DevicesUseCases?, DeviceCourtsProvider?>(
      create: (context) => null,
      update: (context, useCases, previousProvider) {
        // Si no existe el caso de uso pero sí existe un CourtsProvider, no crear uno nuevo
        if (useCases == null || previousProvider != null) {
          return previousProvider;
        }

        return DeviceCourtsProvider(devicesUseCases: useCases);
      },
    ),

    ChangeNotifierProxyProvider<ReservationsUseCases?, ReservationsListProvider?>(
      create: (context) => null,
      update: (context, useCases, previousProvider) {
        // Si no existe el caso de uso pero sí existe un CourtsProvider, no crear uno nuevo
        if (useCases == null || previousProvider != null) {
          return previousProvider;
        }

        return ReservationsListProvider(reservationsUseCases: useCases);
      },
    ),

    ChangeNotifierProxyProvider<ReservationsUseCases?, ReservationProvider?>(
      create: (context) => null,
      update: (context, useCases, previousProvider) {
        // Si no existe el caso de uso pero sí existe un CourtsProvider, no crear uno nuevo
        if (useCases == null || previousProvider != null) {
          return previousProvider;
        }

        return ReservationProvider(reservationsUseCases: useCases);
      },
    ),

    ChangeNotifierProxyProvider2<DevicesUseCases?, CourtsUseCases?, TelemetryProvider?>(
      create: (context) => null,
      update: (context, useCases1, useCases2, previousProvider) {
        // Si no existe el caso de uso pero sí existe un CourtsProvider, no crear uno nuevo
        if (useCases1 == null || useCases2 == null || previousProvider != null) {
          return previousProvider;
        }

        return TelemetryProvider(devicesUseCases: useCases1, courtsUseCases: useCases2);
      },
    ),

    ChangeNotifierProvider<TimeRangeController>(create: (_) => TimeRangeController()),
  ];
}
