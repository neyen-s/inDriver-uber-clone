import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/presentation/pages/auth/login/sign_in_page.dart';
import 'package:indriver_uber_clone/presentation/pages/auth/sign-up/sign_up_page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  print('generateRoute /');

  switch (settings.name) {
    case '/':
      print('RUTA /');
      return _pageBuilder((_) => const SignInPage(), settings: settings);
    case SignInPage.routeName:
      print('SignInPage.routeName');

      return _pageBuilder((_) => const SignInPage(), settings: settings);

    case SignUpPage.routeName:
      print('SignUpPage.routeName');

      return _pageBuilder((_) => const SignUpPage(), settings: settings);
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
