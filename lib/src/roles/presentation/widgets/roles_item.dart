import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_role_entity.dart';
import 'package:indriver_uber_clone/core/services/injection_container.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/drivers-position/delete_driver_position_usecase.dart';
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
        final socketBloc = context.read<SocketBloc>();
        final rolesBloc = context.read<RolesBloc>();
        final authUseCases = sl<AuthUseCases>();
        final sessionRes = await authUseCases.getUserSessionUseCase();
        final session = sessionRes.fold((f) => null, (s) => s);

        if (session?.user.id != null) {
          final idDriver = session!.user.id;

          try {
            final deleteUsecase = sl<DeleteDriverPositionUsecase>();
            final result = await deleteUsecase(idDriver: idDriver);

            result.fold(
              (failure) => debugPrint('Delete failed: ${failure.message}'),
              (msg) => debugPrint('Delete success: $msg'),
            );
          } catch (e) {
            debugPrint('Error deleting driver position: $e');
          }

          socketBloc.add(DisconnectSocket());

          // Wait for SocketDisconnected or SocketError
          try {
            await socketBloc.stream
                .firstWhere((s) => s is SocketDisconnected || s is SocketError)
                .timeout(const Duration(seconds: 2));
          } catch (_) {
            debugPrint(
              'RolesItem: timeout waiting for SocketDisconnected (continuing)',
            );
          }
          //Clean markers and reconnect
          context.read<ClientMapSeekerBloc>().add(const ClearDriverMarkers());
          socketBloc.add(ConnectSocket());
        }
        //Role selection and navigation
        rolesBloc.add(SelectRole(widget.role));
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
