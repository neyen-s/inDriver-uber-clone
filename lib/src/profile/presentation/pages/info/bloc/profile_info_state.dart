part of 'profile_info_bloc.dart';

sealed class ProfileInfoState extends Equatable {
  const ProfileInfoState();

  @override
  List<Object> get props => [];
}

final class ProfileInfoInitial extends ProfileInfoState {
  const ProfileInfoInitial();
}

final class ProfileInfoLoading extends ProfileInfoState {
  const ProfileInfoLoading();
}

final class ProfileInfoLoaded extends ProfileInfoState {
  const ProfileInfoLoaded(this.user);
  final AuthResponseEntity user;

  @override
  List<Object> get props => [user];
}

final class ProfileInfoError extends ProfileInfoState {
  const ProfileInfoError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
