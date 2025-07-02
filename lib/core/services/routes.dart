import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/sign_in_page.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-up/sign_up_page.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/splash/splash_page.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/client_home_page.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/info/profile_info_page.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/profile_update_page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  print('generateRoute /');

  switch (settings.name) {
    case '/':
      print('RUTA /');
      return _pageBuilder((_) => const SignInPage(), settings: settings);

    case SignInPage.routeName:
      print('SignInPage.routeName');
      return _pageBuilder((_) => const SignInPage(), settings: settings);

    case SplashPage.routeName:
      return _pageBuilder((_) => const SplashPage(), settings: settings);

    case SignUpPage.routeName:
      print('SignUpPage.routeName');
      return _pageBuilder((_) => const SignUpPage(), settings: settings);

    case ClientHomePage.routeName:
      print('ClientHomePage.routeName');
      return _pageBuilder((_) => const ClientHomePage(), settings: settings);
    case ProfileInfoPage.routeName:
      print('ProfileInfoPage.routeName');
      return _pageBuilder((_) => const ProfileInfoPage(), settings: settings);

    case ProfileUpdatePage.routeName:
      print('ProfileUpdatePage.routeName');
      return _pageBuilder((_) => const ProfileUpdatePage(), settings: settings);

    default:
      print('RUTA DEFAULT');
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
