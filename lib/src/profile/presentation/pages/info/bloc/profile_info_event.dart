part of 'profile_info_bloc.dart';

sealed class ProfileInfoEvent extends Equatable {
  const ProfileInfoEvent();

  @override
  List<Object> get props => [];
}

class LoadUserProfile extends ProfileInfoEvent {
  const LoadUserProfile();
}
