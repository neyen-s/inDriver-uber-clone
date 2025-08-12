part of 'driver_home_bloc.dart';

sealed class DriverHomeState extends Equatable {
  const DriverHomeState(this.section);
  final GenericHomeScaffoldSection section;

  @override
  List<Object> get props => [section];
}

final class DriverHomeInitial extends DriverHomeState {
  const DriverHomeInitial() : super(GenericHomeScaffoldSection.map);
}

final class SignOutSuccess extends DriverHomeState {
  const SignOutSuccess() : super(GenericHomeScaffoldSection.profile);
}

final class DriverHomeChanged extends DriverHomeState {
  const DriverHomeChanged(super.section);
}

final class DriverHomeSuccess extends DriverHomeState {
  const DriverHomeSuccess() : super(GenericHomeScaffoldSection.map);
}
