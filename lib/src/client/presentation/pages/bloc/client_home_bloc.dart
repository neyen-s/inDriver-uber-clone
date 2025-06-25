import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';

part 'client_home_event.dart';
part 'client_home_state.dart';

class ClientHomeBloc extends Bloc<ClientHomeEvent, ClientHomeState> {
  ClientHomeBloc() : super(const ClientHomeInitial()) {
    on<ChangeDrawerSection>((event, emit) {
      emit(ClientHomeChanged(event.section));
    });
  }
}
