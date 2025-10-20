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
    //Clean markers and reconnect
    try {
      context.read<ClientMapSeekerBloc>().add(const ClearDriverMarkers());
    } catch (_) {}
    debugPrint('sockect discconnect');
    // Connects on background
    socketBloc.add(DisconnectSocket());

    debugPrint('sockect connect');
    socketBloc.add(ConnectSocket());

    debugPrint('redirect user ');
    RoleRouter.redirectUser(context, roles);
  }
}
