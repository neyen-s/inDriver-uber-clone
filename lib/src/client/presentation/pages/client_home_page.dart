import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/bloc/client_home_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/profile_info_page.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  static const routeName = '/client-home';

  Widget _buildBody(ClientHomeSection section) {
    switch (section) {
      case ClientHomeSection.profile:
        return const ProfileInfoPage();
      case ClientHomeSection.map:
        return const Center(child: Text('Mapa (por implementar)'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu options')),
      body: BlocBuilder<ClientHomeBloc, ClientHomeState>(
        builder: (context, state) {
          return _buildBody(state.section);
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0E1D6A), Color(0xFF1E70E3)],
                ),
              ),
              child: Text('Client Menu', style: TextStyle(color: Colors.white)),
            ),
            _buildDrawerItem(
              context,
              label: 'Perfil',
              section: ClientHomeSection.profile,
            ),
            _buildDrawerItem(
              context,
              label: 'Mapa',
              section: ClientHomeSection.map,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required String label,
    required ClientHomeSection section,
  }) {
    final currentSection = context.select(
      (ClientHomeBloc bloc) => bloc.state.section,
    );
    final isSelected = currentSection == section;

    return ListTile(
      title: Text(label),
      selected: isSelected,
      onTap: () {
        if (!isSelected) {
          context.read<ClientHomeBloc>().add(ChangeDrawerSection(section));
        }
        Navigator.pop(context); // cerrar el drawer
      },
    );
  }
}
