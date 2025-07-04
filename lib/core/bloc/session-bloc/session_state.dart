part of 'session_bloc.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object> get props => [];
}

class SessionInitial extends SessionState {
  const SessionInitial();
}

class SessionActive extends SessionState {
  const SessionActive();
}

class SessionTerminated extends SessionState {
  const SessionTerminated();
}
