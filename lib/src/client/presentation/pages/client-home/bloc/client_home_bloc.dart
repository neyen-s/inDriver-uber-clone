// client_home_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';

part 'client_home_event.dart';
part 'client_home_state.dart';

class ClientHomeBloc extends Bloc<ClientHomeEvent, ClientHomeState> {
  ClientHomeBloc(this.authUseCases) : super(const ClientHomeInitial()) {
    on<ChangeDrawerSection>((event, emit) {
      emit(ClientHomeChanged(event.section));
    });

    on<SignOutRequested>(_onSignOutRequested);
  }

  final AuthUseCases authUseCases;

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<ClientHomeState> emit,
  ) async {
    final result = await authUseCases.signOutUseCase();
    result.fold((failure) {}, (_) => emit(const SignOutSuccess()));
  }
}
