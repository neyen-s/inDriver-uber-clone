import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/bloc/session-bloc/session_bloc.dart';
import 'package:indriver_uber_clone/core/injection/bloc_providers.dart';
import 'package:indriver_uber_clone/core/services/app_navigator_service.dart';
import 'package:indriver_uber_clone/core/services/injection_container.dart';
import 'package:indriver_uber_clone/core/services/routes.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/remote/sesion_manager.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/sign_in_page.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/splash/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  //***FOR TESTING***
  await SessionManager.clearSession();

  runApp(DevicePreview(builder: (context) => const MyAppWrapper()));
}

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) =>
          MultiBlocProvider(providers: BlocProviders.all, child: const MyApp()),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listener: (context, state) {
        if (state is SessionTerminated) {
          sl<AppNavigatorService>().navigateToLogin();
        }
      },
      child: MaterialApp(
        navigatorKey: sl<AppNavigatorService>().navigatorKey,
        builder: DevicePreview.appBuilder,
        locale: DevicePreview.locale(context),
        debugShowCheckedModeBanner: false,
        title: 'Mi App',
        initialRoute: SplashPage.routeName,
        onGenerateRoute: generateRoute,
      ),
    );
  }
}
