part of 'client_home_bloc.dart';

sealed class ClientHomeState extends Equatable {
  const ClientHomeState(this.section);
  final ClientHomeSection section;

  @override
  List<Object> get props => [section];
}

final class ClientHomeInitial extends ClientHomeState {
  const ClientHomeInitial() : super(ClientHomeSection.profile);
}

final class ClientHomeChanged extends ClientHomeState {
  const ClientHomeChanged(super.section);
}
