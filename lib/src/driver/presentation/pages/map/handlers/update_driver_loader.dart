import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/services/loader_service.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/map/bloc/driver_map_bloc.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/map/cubit/driver_map_life_cycle_cubit.dart';

void updateDriverLoader(BuildContext context) {
  final driverState = context.read<DriverMapBloc>().state;
  final mapLifecycle = context.read<DriverMapLifeCycleCubit>().state;

  final mapReady = mapLifecycle == DriverMapLifeCycleEnum.ready;

  var shouldShow = false;

  if (driverState is DriverMapLoading ||
      driverState is DriverMapInitial ||
      !mapReady) {
    shouldShow = true;
  } else {
    shouldShow = !mapReady;
  }

  if (shouldShow) {
    LoadingService.show(context, message: 'Loading location...');
  } else {
    LoadingService.hide(context);
  }
}
