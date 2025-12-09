import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/bloc/session-bloc/session_bloc.dart';
import 'package:indriver_uber_clone/core/injection/bloc_providers.dart';
import 'package:indriver_uber_clone/core/services/app_navigator_service.dart';
import 'package:indriver_uber_clone/core/services/injection_container.dart';
import 'package:indriver_uber_clone/core/services/routes.dart';
import 'package:indriver_uber_clone/core/services/secure_storage_adapter.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/splash/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SecureStorageAdapter.init();
  await init();
  //***FOR TESTING***
  // await SessionManager.clearSessi on();
  // Lock to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    DevicePreview(
      enabled: true,
      // Disable for production,
      //genertares unwanted spaces when the keyboard appears
      builder: (context) => const MyAppWrapper(),
    ),
  );
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
        // navigatorObservers: [routeObserver],
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
