part of 'profile_update_bloc.dart';

sealed class ProfileUpdateEvent extends Equatable {
  const ProfileUpdateEvent();

  @override
  List<Object?> get props => [];
}

class ProfileUpdateNameChanged extends ProfileUpdateEvent {
  const ProfileUpdateNameChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

class ProfileUpdateLastnameChanged extends ProfileUpdateEvent {
  const ProfileUpdateLastnameChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class ProfilePhoneChanged extends ProfileUpdateEvent {
  const ProfilePhoneChanged(this.phone);
  final String phone;

  @override
  List<Object?> get props => [phone];
}

class ProfileImageChanged extends ProfileUpdateEvent {
  const ProfileImageChanged(this.image);
  final File image;
}

final class SubmitProfileChanges extends ProfileUpdateEvent {
  const SubmitProfileChanges();
}
