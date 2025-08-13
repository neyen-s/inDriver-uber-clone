import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_role_entity.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/sign_in_page.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/client-home/client_home_page.dart';
import 'package:indriver_uber_clone/src/roles/presentation/pages/roles_page.dart';

class RoleRouter {
  static void redirectUser(BuildContext context, List<UserRoleEntity> roles) {
    if (roles.any((r) => r.id == 'DRIVER')) {
      debugPrint('is DRIVER');
      Navigator.pushReplacementNamed(context, RolesPage.routeName);
    } else if (roles.any((r) => r.id == 'CLIENT')) {
      debugPrint('is CLIENT');
      Navigator.pushReplacementNamed(context, ClientHomePage.routeName);
    } else {
      debugPrint('---ELSE DEFAULT---');
      Navigator.pushReplacementNamed(context, SignInPage.routeName);
    }
  }
}
