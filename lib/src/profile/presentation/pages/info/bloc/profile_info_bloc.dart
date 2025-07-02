import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/auth_response_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/get_user_session_use_case.dart';

part 'profile_info_event.dart';
part 'profile_info_state.dart';

class ProfileInfoBloc extends Bloc<ProfileInfoEvent, ProfileInfoState> {
  ProfileInfoBloc(this.getUserSession) : super(const ProfileInfoInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
  }
  final GetUserSessionUseCase getUserSession;

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<ProfileInfoState> emit,
  ) async {
    emit(const ProfileInfoLoading());

    final result = await getUserSession();

    result.fold(
      (failure) => emit(ProfileInfoError(failure.errorMessage)),
      (authResponse) => emit(ProfileInfoLoaded(authResponse)),
    );
  }
}
