part of 'profile_update_bloc.dart';

sealed class ProfileUpdateEvent extends Equatable {
  const ProfileUpdateEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileNameChanged extends ProfileUpdateEvent {
  const ProfileNameChanged(this.name);
  final String name;

  @override
  List<Object?> get props => [name];
}

final class ProfileLastnameChanged extends ProfileUpdateEvent {
  const ProfileLastnameChanged(this.lastname);
  final String lastname;

  @override
  List<Object?> get props => [lastname];
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

  @override
  List<Object?> get props => [];
}
