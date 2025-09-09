part of 'roles_bloc.dart';

sealed class RolesState extends Equatable {
  const RolesState();

  @override
  List<Object> get props => [];
}

final class RolesInitial extends RolesState {}

final class RolesLoading extends RolesState {}

final class RolesError extends RolesState {
  const RolesError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

final class RolesLoaded extends RolesState {
  const RolesLoaded(this.roles);

  final List<UserRoleEntity> roles;

  @override
  List<Object> get props => [roles];
}

final class RoleSelected extends RolesState {
  const RoleSelected(this.role);

  final UserRoleEntity role;

  @override
  List<Object> get props => [role];
}
