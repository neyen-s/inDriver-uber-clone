import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'map_lyfe_cycle_state.dart';

enum MapLifecycleState { initializing, ready }

class MapLifecycleCubit extends Cubit<MapLifecycleState> {
  MapLifecycleCubit() : super(MapLifecycleState.initializing);

  void markReady() => emit(MapLifecycleState.ready);
  void reset() => emit(MapLifecycleState.initializing);
}
