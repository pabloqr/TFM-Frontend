import 'package:flutter/cupertino.dart';
import 'package:frontend/features/auth/presentation/screens/sign_up_sign_in_screen.dart';
import 'package:frontend/features/common/presentation/screens/settings_screen.dart';
import 'package:frontend/features/complexes/presentation/screens/complex_info_screen.dart';
import 'package:frontend/features/courts/presentation/screens/court_info_screen.dart';
import 'package:frontend/features/reservations/presentation/screens/reservation_info_screen.dart';
import 'package:frontend/features/reservations/presentation/screens/reservation_screen.dart';

class AppConstants {
  static String baseUrl = _defaultBaseUrl;

  static const String _defaultBaseUrl = 'http://100.70.62.176:3000';

  // Definición de los endpoints de la API del backend del sistema, para evitar la duplicidad de las entradas en el
  // código, los métodos CRUD se agruparán para cada uno de los módulos del sistema de la siguiente manera:
  //  * Read (GET all): moduloEndpoint
  //  * Create/Read (GET all, POST): moduloCREndpoint
  //  * Update/Delete/Read by ID (GET by ID, PUT, DELETE): moduloUDEndpoint(id)
  static const String authEndpoint = '/auth';

  static const String complexesEndpoint = '/complexes';

  static String complexesByIdEndpoint(String complexId) => '$complexesEndpoint/$complexId';

  static const String courtsEndpoint = '/courts';

  static String courtsByIdEndpoint(String courtId) => '$courtsEndpoint/$courtId';

  static const String devicesEndpoint = '/devices';

  static String devicesByIdEndpoint(String deviceId) => '$devicesEndpoint/$deviceId';

  static const String newsEndpoint = '/news';

  static String newsByIdEndpoint(String newsId) => '$newsEndpoint/$newsId';

  static const String reservationsEndpoint = '/reservations';

  static String reservationsByIdEndpoint(String reservationId) => '$reservationsEndpoint/$reservationId';

  static const String usersEndpoint = '/users';

  static String usersByIdEndpoint(String userId) => '$usersEndpoint/$userId';

  static const String notificationsEndpoint = '/notifications';

  static String notificationsByIdEndpoint(String notificationId) => '$notificationsEndpoint/$notificationId';

  //------------------------------------------------------------------------------------------------------------------//
  // AUTH ENDPOINTS
  //------------------------------------------------------------------------------------------------------------------//
  static const String signUpEndpoint = '$authEndpoint/signup';
  static const String signInEndpoint = '$authEndpoint/signin';
  static const String refreshTokenEndpoint = '$authEndpoint/refresh-token';
  static const String signOutEndpoint = '$authEndpoint/signout';
  static const String forgotPasswordEndpoint = '$authEndpoint/forgot-password';
  static const String resetPasswordEndpoint = '$authEndpoint/reset-password';

  //------------------------------------------------------------------------------------------------------------------//
  // COMPLEXES ENDPOINTS
  //------------------------------------------------------------------------------------------------------------------//
  static const String complexesCREndpoint = complexesEndpoint;

  static String complexesUDEndpoint(String complexId) => complexesByIdEndpoint(complexId);

  static String complexTimeEndpoint(String complexId) => '${complexesByIdEndpoint(complexId)}/time';

  static String complexAvailabilityEndpoint(String complexId) => '${complexesByIdEndpoint(complexId)}/availability';

  //------------------------------------------------------------------------------------------------------------------//
  // COURTS ENDPOINTS
  //------------------------------------------------------------------------------------------------------------------//
  static String courtsCREndpoint(String complexId) => '${complexesByIdEndpoint(complexId)}$courtsEndpoint';

  static String courtsUDEndpoint(String complexId, String courtId) =>
      '${complexesByIdEndpoint(complexId)}${courtsByIdEndpoint(courtId)}';

  static String courtStatusEndpoint(String complexId, String courtId) =>
      '${complexesByIdEndpoint(complexId)}${courtsByIdEndpoint(courtId)}/status';

  static String courtAvailabilityEndpoint(String complexId, String courtId) =>
      '${complexesByIdEndpoint(complexId)}${courtsByIdEndpoint(courtId)}/availability';

  static String courtDevicesEndpoint(String complexId, String courtId) =>
      '${complexesByIdEndpoint(complexId)}${courtsByIdEndpoint(courtId)}/devices';

  //------------------------------------------------------------------------------------------------------------------//
  // DEVICES ENDPOINTS
  //------------------------------------------------------------------------------------------------------------------//
  static String devicesCREndpoint(String complexId) => '${complexesByIdEndpoint(complexId)}$devicesEndpoint';

  static String devicesUDEndpoint(String complexId, String deviceId) =>
      '${complexesByIdEndpoint(complexId)}${devicesByIdEndpoint(deviceId)}';

  static String devicesTelemetryEndpoint(String complexId, String deviceId) =>
      '${complexesByIdEndpoint(complexId)}${devicesByIdEndpoint(deviceId)}/telemetry';

  static String devicesStatusEndpoint(String complexId, String deviceId) =>
      '${complexesByIdEndpoint(complexId)}${devicesByIdEndpoint(deviceId)}/status';

  static String devicesCourtsEndpoint(String complexId, String deviceId) =>
      '${complexesByIdEndpoint(complexId)}${devicesByIdEndpoint(deviceId)}/courts';

  //------------------------------------------------------------------------------------------------------------------//
  // NEWS ENDPOINTS
  //------------------------------------------------------------------------------------------------------------------//
  static const String newsCREndpoint = newsEndpoint;

  static String newsUDEndpoint(String newsId) => newsByIdEndpoint(newsId);

  //------------------------------------------------------------------------------------------------------------------//
  // RESERVATIONS ENDPOINTS
  //------------------------------------------------------------------------------------------------------------------//
  static String reservationsUDEndpoint(String reservationId) => reservationsByIdEndpoint(reservationId);

  static String reservationsComplexesCREndpoint(String complexId) =>
      '${complexesByIdEndpoint(complexId)}$reservationsEndpoint';

  static String reservationsUsersEndpoint(String userId) => '${usersByIdEndpoint(userId)}$reservationsEndpoint';

  //------------------------------------------------------------------------------------------------------------------//
  // USERS ENDPOINTS
  //------------------------------------------------------------------------------------------------------------------//
  static const String usersCREndpoint = usersEndpoint;

  static String usersUDEndpoint(String userId) => usersByIdEndpoint(userId);

  //------------------------------------------------------------------------------------------------------------------//
  // NOTIFICATIONS ENDPOINTS
  //------------------------------------------------------------------------------------------------------------------//
  // TODO: Add endpoints for notifications
  static const String notificationsCREndpoint = notificationsEndpoint;

  static String notificationsUDEndpoint(String id) => '$notificationsEndpoint/$id';

  //------------------------------------------------------------------------------------------------------------------//
  // APP ROUTES
  //------------------------------------------------------------------------------------------------------------------//
  static const String welcomeRoute = '/welcome';
  static const String signUpRoute = signUpEndpoint;
  static const String signInRoute = signInEndpoint;
  static const String clientHomeRoute = '/client/home';
  static const String adminHomeRoute = '/admin/home';
  static const String clientSettingsRoute = '/client/settings';
  static const String adminSettingsRoute = '/admin/settings';
  static const String complexInfoRoute = '$complexesEndpoint/info';
  static const String courtInfoRoute = '$courtsEndpoint/info';
  static const String reservationNewRoute = '$reservationsEndpoint/new';
  static const String reservationModifyRoute = '$reservationsEndpoint/modify';
  static const String reservationInfoRoute = '$reservationsEndpoint/info';

  static final Map<String, Widget Function(BuildContext)> routes = {
    // welcomeRoute: (context) => const WelcomeScreen(),
    signUpRoute: (context) => const SignUpScreen(),
    signInRoute: (context) => const SignInScreen(),
    clientSettingsRoute: (context) => const SettingsScreen(),
    adminSettingsRoute: (context) => const SettingsScreen(),
    complexInfoRoute: (context) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is Map<String, dynamic>) {
        return ComplexInfoScreen(complexId: arguments['complexId'] as int);
      }

      return const ComplexInfoScreen(complexId: 0);
    },
    courtInfoRoute: (context) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is Map<String, dynamic>) {
        return CourtInfoScreen(complexId: arguments['complexId'] as int, courtId: arguments['courtId'] as int);
      }

      return const CourtInfoScreen(complexId: 0, courtId: 0);
    },
    reservationNewRoute: (context) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is Map<String, dynamic>) {
        return ReservationScreen.create(isAdmin: arguments['isAdmin'] as bool);
      }

      return ReservationScreen.create(isAdmin: false);
    },
    reservationModifyRoute: (context) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is Map<String, dynamic>) {
        return ReservationScreen.modify(isAdmin: arguments['isAdmin'] as bool);
      }

      return ReservationScreen.modify(isAdmin: false);
    },
    reservationInfoRoute: (context) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is Map<String, dynamic>) {
        return ReservationInfoScreen(
          complexId: arguments['complexId'] as int,
          courtId: arguments['courtId'] as int,
          reservationId: arguments['reservationId'] as int,
        );
      }

      return const ReservationInfoScreen(complexId: 0, courtId: 0, reservationId: 0);
    },
  };
}
