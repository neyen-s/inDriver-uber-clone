import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/utils/core_utils.dart';
import 'package:indriver_uber_clone/core/utils/role_router.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/bloc/sign_in_bloc.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/sign_in_page.dart';
import 'package:indriver_uber_clone/src/auth/presentation/widgets/auth_background.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';

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
    context.read<SignInBloc>().add(const CheckUserSession());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: BlocListener<SignInBloc, SignInState>(
        listener: (context, state) async {
          debugPrint('------SplashPage Listener-----');
          debugPrint('------STATE $state-----');

          if (state is SessionValid) {
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
          padding: EdgeInsets.only(left: 12.w),

          child: const Center(
            child: CircularProgressIndicator(),
          ), // TODOSWITCH THE LOADER
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
    debugPrint('roles: $roles');

    // Limpia markers (si aplica)
    try {
      context.read<ClientMapSeekerBloc>().add(const ClearDriverMarkers());
    } catch (_) {}

    // No forces disconnect salvo que realmente lo necesites:
    // socketBloc.add(DisconnectSocket());

    // Intenta conectar (no bloqueante)
    socketBloc.add(ConnectSocket());

    // Espera un momento a que el socket pase a SocketConnected
    final connected = await _waitForSocketConnected(socketBloc);
    debugPrint('Splash page: socket connected? $connected');

    // Redirige (si no está conectado, la pantalla destino deberá pedir RequestInitialDrivers)
    RoleRouter.redirectUser(context, roles);
  }

  // helper en el mismo archivo SplashPage (o util)
  Future<bool> _waitForSocketConnected(
    SocketBloc socketBloc, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    // si ya está conectado, return true
    if (socketBloc.state is SocketConnected) return true;

    final completer = Completer<bool>();
    StreamSubscription? sub;
    sub = socketBloc.stream.listen((state) {
      if (state is SocketConnected) {
        if (!completer.isCompleted) completer.complete(true);
        sub?.cancel();
      } else if (state is SocketError) {
        // no cancelamos aquí: un error no implica que no vaya a reconectar,
        // solo lo ignoramos y seguimos esperando hasta timeout
      }
    });

    // timeout fallback
    await Future.delayed(timeout).then((_) {
      if (!completer.isCompleted) {
        completer.complete(false);
        sub?.cancel();
      }
    });

    return completer.future;
  }
}
