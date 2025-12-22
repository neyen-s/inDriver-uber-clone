import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget makeTestApp({
  required Widget child,
  List<BlocProvider> blocProviders = const [],
}) {
  return ScreenUtilInit(
    builder: (_, _) {
      return MaterialApp(
        home: Scaffold(
          body: MultiBlocProvider(providers: blocProviders, child: child),
        ),
      );
    },
  );
}

Widget makeWidgetTestApp({required Widget child, bool initScreenUtil = true}) {
  return ScreenUtilInit(
    minTextAdapt: true,
    builder: (_, _) {
      return MaterialApp(home: Scaffold(body: child));
    },
  );
}
