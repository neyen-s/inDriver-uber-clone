import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_role_entity.dart';
import 'package:indriver_uber_clone/core/services/injection_container.dart';
import 'package:indriver_uber_clone/core/services/loader_service.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/drivers-position/delete_driver_position_usecase.dart';
import 'package:indriver_uber_clone/src/roles/presentation/bloc/roles_bloc.dart';
import 'package:indriver_uber_clone/src/roles/presentation/utils/normalize_urls.dart';

class RolesItem extends StatefulWidget {
  const RolesItem({required this.role, super.key});

  final UserRoleEntity role;

  @override
  State<RolesItem> createState() => _RolesItemState();
}

class _RolesItemState extends State<RolesItem> {
  @override
  void initState() {
    super.initState();
    // pre-cache para reducir parpadeo la primera vez (opcional)
    final url = normalizeUrl(widget.role.image);
    if (url != null &&
        (url.startsWith('http://') || url.startsWith('https://'))) {
      // Intentamos precache, ignoramos errores
      try {
        precacheImage(NetworkImage(url), context);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = normalizeUrl(widget.role.image);

    return GestureDetector(
      onTap: () async {
        LoadingService.show(context, message: 'Loading User...');
        // CAPTURAR referencias ANTES de cualquier await
        final socketBloc = context.read<SocketBloc>();
        final rolesBloc = context.read<RolesBloc>();
        final clientMapSeekerBloc = context.read<ClientMapSeekerBloc>();
        final authUseCases = sl<AuthUseCases>();
        final deleteUsecase = sl<DeleteDriverPositionUsecase>();

        // Obtener sesión
        final sessionRes = await authUseCases.getUserSessionUseCase();
        final session = sessionRes.fold((f) => null, (s) => s);

        if (session?.user.id != null) {
          final idDriver = session!.user.id;

          // Borrar backend driver position (esperar resultado)
          try {
            final result = await deleteUsecase(idDriver: idDriver);
            result.fold(
              (failure) => debugPrint('Delete failed: ${failure.message}'),
              (msg) => debugPrint('Delete success: $msg'),
            );
          } catch (e) {
            debugPrint('Error deleting driver position: $e');
          }

          // Pedimos desconexión si está conectado; al desconectar se limpian subs internamente
          socketBloc.add(DisconnectSocket());

          // esperar a que el bloc emita SocketDisconnected o SocketError (timeout corto)
          try {
            await socketBloc.stream
                .firstWhere((s) => s is SocketDisconnected || s is SocketError)
                .timeout(const Duration(seconds: 3));
          } catch (_) {
            debugPrint(
              'RolesItem: timeout waiting for SocketDisconnected (continuing)',
            );
          }
          //TODO DELETE THIS LINE
          await Future.delayed(const Duration(milliseconds: 180));

          // Limpiar markers localmente (usa la referencia capturada)
          clientMapSeekerBloc.add(const ClearDriverMarkers());

          // Reconectar y ESPERAR a que emita SocketConnected (o SocketError)
          socketBloc.add(ConnectSocket());
          try {
            await socketBloc.stream
                .firstWhere((s) => s is SocketConnected || s is SocketError)
                .timeout(const Duration(seconds: 3));
          } catch (_) {
            debugPrint(
              'RolesItem: timeout waiting for SocketConnected (continuing)',
            );
          }
        }

        // Selección de rol y navegación (usar rolesBloc referencia capturada)
        rolesBloc.add(SelectRole(widget.role));
        LoadingService.hide(context);

        // Navegación: aquí sí usamos context porque estamos a punto de salir
        await Navigator.pushReplacementNamed(context, widget.role.route);
      },
      child: Column(
        children: [
          SizedBox(
            height: 100.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: FadeInImage(
                placeholder: const AssetImage('assets/img/no-image.png'),
                image:
                    imageUrl != null &&
                        (imageUrl.startsWith('http') ||
                            imageUrl.startsWith('https'))
                    ? NetworkImage(imageUrl) as ImageProvider
                    : const AssetImage('assets/img/no-image.png'),
                fit: BoxFit.contain,
                fadeInDuration: const Duration(milliseconds: 400),
              ),
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
