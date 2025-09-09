import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_role_entity.dart';
import 'package:indriver_uber_clone/core/services/loader_service.dart';
import 'package:indriver_uber_clone/core/utils/core_utils.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';
import 'package:indriver_uber_clone/src/roles/presentation/bloc/roles_bloc.dart';

class RolesItem extends StatefulWidget {
  const RolesItem({required this.role, super.key});

  final UserRoleEntity role;

  @override
  State<RolesItem> createState() => _RolesItemState();
}

class _RolesItemState extends State<RolesItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // LoadingService.show(context, message: 'Loading Role...');

        final socketBloc = context.read<SocketBloc>();

        if (widget.role.id == 'CLIENT') {
          socketBloc.add(DisconnectSocket());
          context.read<ClientMapSeekerBloc>().add(const ClearDriverMarkers());
          socketBloc.add(ConnectSocket());
        }

        // Avisamos al RolesBloc qué rol eligió
        context.read<RolesBloc>().add(SelectRole(widget.role));

        print('navigating to ${widget.role.route}');
        //  LoadingService.hide(context);

        await Navigator.pushReplacementNamed(context, widget.role.route);
      },
      child: Column(
        children: [
          SizedBox(
            height: 100.h,
            child: FadeInImage(
              image: NetworkImage(widget.role.image),
              fit: BoxFit.contain,
              fadeInDuration: const Duration(seconds: 1),
              placeholder: const AssetImage('assets/img/no-image.png'),
            ),
          ),
          SizedBox(height: 10.h),

          Text(
            widget.role.name,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
