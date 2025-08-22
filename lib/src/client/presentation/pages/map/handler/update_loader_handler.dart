import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/services/loader_service.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/cubit/map_lyfe_cycle_cubit.dart';

void updateLoader(BuildContext context) {
  final clientState = context.read<ClientMapSeekerBloc>().state;
  final mapLifecycle = context.read<MapLifecycleCubit>().state;

  final blocLoading =
      clientState is ClientMapSeekerLoading ||
      clientState is ClientMapSeekerInitial;

  final mapReady = mapLifecycle == MapLifecycleState.ready;

  if (blocLoading || !mapReady) {
    LoadingService.show(context, message: 'Loading location...');
  } else {
    LoadingService.hide(context);
  }
}
