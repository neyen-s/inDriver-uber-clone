import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/common/widgets/scaffold/drawer_items.dart';
import 'package:indriver_uber_clone/core/common/widgets/scaffold/generic_home_scaffold.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/core/services/injection_container.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/sign_in_page.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/client-home/bloc/client_home_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/client_map_seeker_page.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/info/profile_info_page.dart';
import 'package:indriver_uber_clone/src/roles/presentation/pages/roles_page.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  static const routeName = 'client/home';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ClientHomeBloc>(),
      child: BlocListener<ClientHomeBloc, ClientHomeState>(
        listenWhen: (previous, current) => current is SignOutSuccess,
        listener: (context, state) {
          if (state is SignOutSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              SignInPage.routeName,
              (_) => false,
            );
          }
        },
        child: BlocBuilder<ClientHomeBloc, ClientHomeState>(
          builder: (context, state) {
            return GenericHomeScaffold<GenericHomeScaffoldSection>(
              drawerTitle: 'Client Menu',
              drawerItems: [
                DrawerItem(
                  label: 'Map',
                  section: GenericHomeScaffoldSection.map,
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
                    return const ClientMapSeekerPage();
                  case GenericHomeScaffoldSection.clientRequests:
                    return const SizedBox.shrink();
                  case GenericHomeScaffoldSection.profile:
                    return const ProfileInfoPage();
                  case GenericHomeScaffoldSection.driverCarInfo:
                    return const SizedBox.shrink();
                  case GenericHomeScaffoldSection.roles:
                    return const RolesPage();
                }
              },
              onSectionSelected: (section) {
                context.read<ClientHomeBloc>().add(
                  ChangeDrawerSection(section),
                );
              },
              onSignOut: () {
                context.read<ClientHomeBloc>().add(const SignOutRequested());
              },
            );
          },
        ),
      ),
    );
  }
}
