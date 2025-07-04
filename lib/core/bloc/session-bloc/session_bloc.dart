import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc() : super(const SessionInitial()) {
    on<SessionExpired>((event, emit) {
      emit(const SessionTerminated());
    });

    on<SessionStarted>((event, emit) {
      emit(const SessionActive());
    });
  }
}
