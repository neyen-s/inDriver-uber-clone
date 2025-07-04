part of 'session_bloc.dart';

sealed class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object> get props => [];
}

class SessionExpired extends SessionEvent {
  const SessionExpired();
}

class SessionStarted extends SessionEvent {
  const SessionStarted();
}
