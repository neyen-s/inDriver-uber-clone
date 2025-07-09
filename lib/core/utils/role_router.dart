import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_role_entity.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/sign_in_page.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/client-home/client_home_page.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/driver_home_page.dart';

class RoleRouter {
  static void redirectUser(BuildContext context, List<UserRoleEntity> roles) {
    if (roles.any((r) => r.id == 'CLIENT')) {
      Navigator.pushReplacementNamed(context, ClientHomePage.routeName);
    } else if (roles.any((r) => r.id == 'DRIVER')) {
      Navigator.pushReplacementNamed(context, DriverHomePage.routeName);
    } else {
      Navigator.pushReplacementNamed(context, SignInPage.routeName);
    }
  }
}
