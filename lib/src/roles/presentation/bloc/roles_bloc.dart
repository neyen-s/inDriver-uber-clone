import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_role_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';

part 'roles_event.dart';
part 'roles_state.dart';

class RolesBloc extends Bloc<RolesEvent, RolesState> {
  RolesBloc(this.authUseCases) : super(RolesInitial()) {
    on<RolesEvent>(_onGetRolesList);
    on<SelectRole>(_onSelectRole);
  }

  AuthUseCases authUseCases;

  Future<void> _onGetRolesList(
    RolesEvent event,
    Emitter<RolesState> emit,
  ) async {
    emit(RolesLoading());
    final authResponse = await authUseCases.getUserSessionUseCase.call();

    authResponse.fold((failure) => emit(RolesError(failure.message)), (
      authResponseEntity,
    ) {
      final roles = authResponseEntity.user.roles;

      emit(RolesLoaded(roles));
    });
  }

  void _onSelectRole(SelectRole event, Emitter<RolesState> emit) {
    emit(RoleSelected(event.role));
  }
}
