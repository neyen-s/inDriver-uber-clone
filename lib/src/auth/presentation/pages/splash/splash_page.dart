import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/extensions/context_extensions.dart';
import 'package:indriver_uber_clone/core/utils/core_utils.dart';
import 'package:indriver_uber_clone/core/utils/role_router.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/bloc/sign_in_bloc.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/sign_in_page.dart';
import 'package:indriver_uber_clone/src/auth/presentation/widgets/auth_background.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/client-home/client_home_page.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';
import 'package:indriver_uber_clone/src/roles/presentation/pages/roles_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  static const String routeName = '/splash';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    print('SplashPage initState');
    context.read<SignInBloc>().add(const CheckUserSession());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SignInBloc, SignInState>(
        listener: (context, state) async {
          debugPrint('------SplashPage Listener-----');
          debugPrint('------SSTATE $state-----');

          if (state is SessionValid) {
            print('*****VALID SESION HANDÑER ****');
            await validSessionHandler(state, context);
          } else if (state is SessionInvalid) {
            debugPrint('--SessionInvalid--');
            await Navigator.pushReplacementNamed(context, SignInPage.routeName);
          } else if (state is SignInFailure) {
            debugPrint('--SignInFailure--');
            CoreUtils.showSnackBar(context, state.message);
            await Navigator.pushReplacementNamed(context, SignInPage.routeName);
          }
        },
        child: AuthBackground(
          cardHeight: context.height,
          cardWidth: context.width,
          borderRadius: BorderRadius.zero,

          padding: EdgeInsets.only(left: 12.w),
          gradientColors: const [
            Color.fromARGB(255, 12, 38, 145),
            Color.fromARGB(255, 34, 156, 249),
          ],
          child: const Center(
            child: CircularProgressIndicator(),
          ), // TODO SWITCH THE LOADER
        ),
      ),
    );
  }

  Future<void> validSessionHandler(
    SessionValid state,
    BuildContext context,
  ) async {
    final roles = state.authResponse.user.roles;
    final socketBloc = context.read<SocketBloc>();
    print('roles: $roles');
    // limpiar estado cliente (si aplica)
    try {
      context.read<ClientMapSeekerBloc>().add(const ClearDriverMarkers());
    } catch (_) {}
    print('sockect discconnect');
    // Intentamos conectar en background, no bloqueamos navegación.
    socketBloc.add(DisconnectSocket()); // limpia estado previo
    print('sockect connect');

    socketBloc.add(ConnectSocket()); // intenta conectar, pero NO esperamos aquí
    print('redirect user ');

    // Navegamos según roles (no cambiamos role por el resultado del socket)
    RoleRouter.redirectUser(context, roles);

    // Si quieres notificar al usuario si hubo fallo de socket:
    // Pon un BlocListener en la página destino (Client/Driver) que muestre snackbars
    // cuando reciba SocketError, o usa rootScaffoldMessengerKey para notificar desde aquí:
    // ejemplo: rootScaffoldMessengerKey.currentState?.showSnackBar(...)
  }
}
