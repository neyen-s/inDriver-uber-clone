part of 'driver_home_bloc.dart';

sealed class DriverHomeEvent extends Equatable {
  const DriverHomeEvent();

  @override
  List<Object> get props => [];
}

class ChangeDrawerSection extends DriverHomeEvent {
  const ChangeDrawerSection(this.section);
  final GenericHomeScaffoldSection section;

  @override
  List<Object> get props => [section];
}

class SignOutRequested extends DriverHomeEvent {
  const SignOutRequested();
}
