import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';

part 'driver_home_event.dart';
part 'driver_home_state.dart';

class DriverHomeBloc extends Bloc<DriverHomeEvent, DriverHomeState> {
  DriverHomeBloc(this.authUseCases) : super(const DriverHomeInitial()) {
    on<ChangeDrawerSection>((event, emit) {
      emit(DriverHomeChanged(event.section));
    });

    on<SignOutRequested>(_onSignOutRequested);
  }

  final AuthUseCases authUseCases;

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<DriverHomeState> emit,
  ) async {
    final result = await authUseCases.signOutUseCase();
    result.fold((failure) {}, (_) => emit(const SignOutSuccess()));
  }
}
