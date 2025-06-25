import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/extensions/context_extensions.dart';
import 'package:indriver_uber_clone/core/utils/core_utils.dart';
import 'package:indriver_uber_clone/core/utils/role_router.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/bloc/sign_in_bloc.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/sign_in_page.dart';
import 'package:indriver_uber_clone/src/auth/presentation/widgets/auth_background.dart';

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
      body: BlocListener<SignInBloc, SignInState>(
        listener: (context, state) {
          if (state is SessionValid) {
            debugPrint('--SessionValid ${state.authResponse.user.roles}--');
            RoleRouter.redirectUser(context, state.authResponse.user.roles);
          } else if (state is SessionInvalid) {
            debugPrint('--SessionInvalid--');
            Navigator.pushReplacementNamed(context, SignInPage.routeName);
          } else if (state is SignInFailure) {
            debugPrint('--SignInFailure--');
            CoreUtils.showSnackBar(context, state.message);
            Navigator.pushReplacementNamed(context, SignInPage.routeName);
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
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
