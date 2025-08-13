import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/services/injection_container.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/map/bloc/driver_map_bloc.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/map/driver_map_page.dart';

class DriverMapPageWrapper extends StatelessWidget {
  const DriverMapPageWrapper({super.key});
  static const String routeName = 'driver/wrapper';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DriverMapBloc>(),

      child: const DriverMapPage(),
    );
  }
}
