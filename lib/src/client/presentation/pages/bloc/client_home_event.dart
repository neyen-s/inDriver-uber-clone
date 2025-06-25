part of 'client_home_bloc.dart';

sealed class ClientHomeEvent extends Equatable {
  const ClientHomeEvent();
  @override
  List<Object> get props => [];
}

final class ChangeDrawerSection extends ClientHomeEvent {
  const ChangeDrawerSection(this.section);
  final ClientHomeSection section;

  @override
  List<Object> get props => [section];
}

final class SignOutRequested extends ClientHomeEvent {
  const SignOutRequested();
}
