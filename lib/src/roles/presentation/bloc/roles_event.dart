part of 'roles_bloc.dart';

sealed class RolesEvent extends Equatable {
  const RolesEvent();

  @override
  List<Object> get props => [];
}

class GetRolesList extends RolesEvent {}

class SelectRole extends RolesEvent {
  const SelectRole(this.role);

  final UserRoleEntity role;

  @override
  List<Object> get props => [role];
}
