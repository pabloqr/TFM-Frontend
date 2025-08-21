import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/domain/usecases/sign_in_usecase.dart';
import 'package:frontend/domain/usecases/sign_up_usecase.dart';
import 'package:frontend/features/auth/data/services/auth_local_service.dart';
import 'package:frontend/features/auth/data/services/auth_remote_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<SingleChildWidget> get appProviders {
  return [
    // ---------------------------------------------------------------------------------------------------------------//
    // DEPENDENCIAS BASE
    // ---------------------------------------------------------------------------------------------------------------//
    Provider<http.Client>(create: (_) => http.Client(), dispose: (_, client) => client.close()),

    Provider<FlutterSecureStorage>(create: (_) => const FlutterSecureStorage()),

    FutureProvider<SharedPreferences?>(create: (_) => SharedPreferences.getInstance(), initialData: null),

    // ---------------------------------------------------------------------------------------------------------------//
    // SERVICIOS
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
    // REPOSITORIOS
    // ---------------------------------------------------------------------------------------------------------------//
    ProxyProvider2<AuthRemoteService, AuthLocalService?, AuthRepository?>(
      update: (context, remoteService, localService, previousAuthRepository) {
        return localService != null
            ? AuthRepositoryImpl(remoteService: remoteService, localService: localService)
            : null;
      },
    ),

    // ---------------------------------------------------------------------------------------------------------------//
    // CASOS DE USO
    // ---------------------------------------------------------------------------------------------------------------//
    ProxyProvider<AuthRepository?, SignUpUseCase?>(
      update: (context, repository, previousSignUpUseCase) {
        return repository != null ? SignUpUseCase(repository: repository) : null;
      },
    ),

    ProxyProvider<AuthRepository?, SignInUseCase?>(
      update: (context, repository, previousSignInUseCase) {
        return repository != null ? SignInUseCase(repository: repository) : null;
      },
    ),
  ];
}
