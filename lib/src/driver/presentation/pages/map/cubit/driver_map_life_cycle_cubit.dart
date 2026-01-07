import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'driver_map_life_cycle_state.dart';

enum DriverMapLifeCycleEnum { initializing, ready }

class DriverMapLifeCycleCubit extends Cubit<DriverMapLifeCycleEnum> {
  DriverMapLifeCycleCubit() : super(DriverMapLifeCycleEnum.initializing);

  void markReady() => emit(DriverMapLifeCycleEnum.ready);
  void reset() => emit(DriverMapLifeCycleEnum.initializing);
}
