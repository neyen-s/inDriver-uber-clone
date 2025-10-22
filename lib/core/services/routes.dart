import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/sign_in_page.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-up/sign_up_page.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/splash/splash_page.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/client-home/client_home_page.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/driver-offers/client_driver_offers_page.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/driver_home_page.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/map/driver_map_page_wrapper.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/info/profile_info_page.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/profile_update_page.dart';
import 'package:indriver_uber_clone/src/roles/presentation/pages/roles_page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  print('******GENERATING ${settings.name}  ROUTE******* ');

  switch (settings.name) {
    case '/':
      debugPrint('RUTA /');
      return _pageBuilder((_) => const SignInPage(), settings: settings);

    case SignInPage.routeName:
      debugPrint('SignInPage.routeName');
      return _pageBuilder((_) => const SignInPage(), settings: settings);

    case SplashPage.routeName:
      return _pageBuilder((_) => const SplashPage(), settings: settings);

    case SignUpPage.routeName:
      debugPrint('SignUpPage.routeName');
      return _pageBuilder((_) => const SignUpPage(), settings: settings);

    case ClientHomePage.routeName:
      debugPrint('ClientHomePage.routeName');
      return _pageBuilder((_) => const ClientHomePage(), settings: settings);
    case ProfileInfoPage.routeName:
      debugPrint('ProfileInfoPage.routeName');
      return _pageBuilder((_) => const ProfileInfoPage(), settings: settings);

    case ProfileUpdatePage.routeName:
      debugPrint('ProfileUpdatePage.routeName');
      return _pageBuilder((_) => const ProfileUpdatePage(), settings: settings);

    case DriverHomePage.routeName:
      debugPrint('DriverHomePage.routeName');
      return _pageBuilder((_) => const DriverHomePage(), settings: settings);

    case RolesPage.routeName:
      debugPrint('RolesPage.routeName');
      return _pageBuilder((_) => const RolesPage(), settings: settings);

    case ClientDriverOffersPage.routeName:
      debugPrint('ClientDriverOffersPage.routeName');
      return _pageBuilder(
        (_) => const ClientDriverOffersPage(),
        settings: settings,
      );

    case DriverMapPageWrapper.routeName:
      debugPrint('RolesPage.routeName');
      return _pageBuilder(
        (_) => const DriverMapPageWrapper(),
        settings: settings,
      );

    default:
      debugPrint('RUTA DEFAULT');
      return _pageBuilder((_) => const SignInPage(), settings: settings);
  }
}

PageRouteBuilder<dynamic> _pageBuilder(
  Widget Function(BuildContext) page, {
  required RouteSettings settings,
}) {
  return PageRouteBuilder(
    settings: settings,
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
    pageBuilder: (context, _, _) => page(context),
  );
}
