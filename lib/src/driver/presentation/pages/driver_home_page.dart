import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/common/widgets/scaffold/drawer_items.dart';
import 'package:indriver_uber_clone/core/common/widgets/scaffold/generic_home_scaffold.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/core/services/injection_container.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/sign_in_page.dart';

import 'package:indriver_uber_clone/src/driver/presentation/pages/bloc/bloc/driver_home_bloc.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/client-requests/driver_client_requests_page.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/map/driver_map_page_wrapper.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/info/profile_info_page.dart';
import 'package:indriver_uber_clone/src/roles/presentation/pages/roles_page.dart';

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});
  static const String routeName = 'driver/home';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DriverHomeBloc>(),

      child: BlocListener<DriverHomeBloc, DriverHomeState>(
        listenWhen: (previous, current) => current is SignOutSuccess,
        listener: (context, state) {
          if (state is SignOutSuccess) {
            //TODO, make sure socket io is disconnected
            Navigator.pushNamedAndRemoveUntil(
              context,
              SignInPage.routeName,
              (_) => false,
            );
          }
        },
        child: BlocBuilder<DriverHomeBloc, DriverHomeState>(
          builder: (context, state) {
            return GenericHomeScaffold<GenericHomeScaffoldSection>(
              drawerTitle: 'Driver Menu',
              drawerItems: [
                DrawerItem(
                  label: 'Map',
                  section: GenericHomeScaffoldSection.map,
                ),
                DrawerItem(
                  label: 'Client Requests',
                  section: GenericHomeScaffoldSection.clientRequests,
                ),
                DrawerItem(
                  label: 'Profile',
                  section: GenericHomeScaffoldSection.profile,
                ),
                DrawerItem(
                  label: 'User Roles',
                  section: GenericHomeScaffoldSection.roles,
                ),
              ],
              selectedSection: state.section,
              buildBody: (section) {
                switch (section) {
                  case GenericHomeScaffoldSection.map:
                    return const DriverMapPageWrapper();
                  case GenericHomeScaffoldSection.clientRequests:
                    return const DriverClientRequestsPage();
                  case GenericHomeScaffoldSection.profile:
                    return const ProfileInfoPage();
                  case GenericHomeScaffoldSection.roles:
                    return const RolesPage();
                }
              },
              onSectionSelected: (section) {
                context.read<DriverHomeBloc>().add(
                  ChangeDrawerSection(section),
                );
              },
              onSignOut: () {
                context.read<DriverHomeBloc>().add(const SignOutRequested());
              },
            );
          },
        ),
      ),
    );
  }
}
