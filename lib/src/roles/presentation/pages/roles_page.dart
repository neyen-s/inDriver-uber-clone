import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_role_entity.dart';
import 'package:indriver_uber_clone/core/extensions/context_extensions.dart';
import 'package:indriver_uber_clone/core/services/loader_service.dart';
import 'package:indriver_uber_clone/core/utils/core_utils.dart';
import 'package:indriver_uber_clone/src/roles/presentation/bloc/roles_bloc.dart';
import 'package:indriver_uber_clone/src/roles/presentation/widgets/roles_item.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});
  static const String routeName = '/roles-page';

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  @override
  void initState() {
    super.initState();
    context.read<RolesBloc>().add(GetRolesList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<RolesBloc, RolesState>(
            listener: (context, state) {
              if (state is RolesLoading) {
                LoadingService.show(context, message: 'Loading roles...');
              } else {
                LoadingService.hide(context);
              }
            },
          ),
          BlocListener<SocketBloc, SocketState>(
            listener: (context, state) async {
              if (state is SocketError) {
                CoreUtils.showSnackBar(context, 'ErrorConnecting to socket');
              }
            },
          ),
        ],
        child: BlocBuilder<RolesBloc, RolesState>(
          builder: (context, state) {
            if (state is RolesError) {
              return Center(child: Text(state.message));
            } else if (state is RolesLoaded) {
              if (state.roles.isEmpty) {
                return const Center(child: Text('No roles available'));
              }

              return Container(
                height: context.height,
                width: context.width,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color.fromARGB(255, 12, 38, 145),
                      Color.fromARGB(255, 34, 156, 249),
                    ],
                  ),
                ),
                child: ListView(
                  shrinkWrap: true,
                  children:
                      state.roles.map((UserRoleEntity role) {
                            return RolesItem(role: role);
                          }).toList()
                          as List<Widget>,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
