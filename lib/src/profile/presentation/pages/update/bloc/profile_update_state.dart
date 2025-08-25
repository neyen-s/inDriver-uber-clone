part of 'profile_update_bloc.dart';

sealed class ProfileUpdateState extends Equatable {
  const ProfileUpdateState();

  @override
  List<Object?> get props => [];
}

final class ProfileUpdateInitial extends ProfileUpdateState {
  const ProfileUpdateInitial({
    this.name = const NameEntity.pure(),
    this.lastname = const LastnameEntity.pure(),
    this.phone = const PhoneEntity.pure(),
  });
  final NameEntity name;
  final LastnameEntity lastname;
  final PhoneEntity phone;

  @override
  List<Object?> get props => [name, lastname, phone];
}

final class ProfileUpdateValidating extends ProfileUpdateState {
  const ProfileUpdateValidating({
    required this.name,
    required this.lastname,
    required this.phone,
  });
  final NameEntity name;
  final LastnameEntity lastname;
  final PhoneEntity phone;

  @override
  List<Object?> get props => [name, lastname, phone];
}

final class ProfileUpdateSubmitting extends ProfileUpdateState {
  const ProfileUpdateSubmitting({
    required this.name,
    required this.lastname,
    required this.phone,
  });
  final NameEntity name;
  final LastnameEntity lastname;
  final PhoneEntity phone;

  @override
  List<Object?> get props => [name, lastname, phone];
}

final class ProfileUpdateSuccess extends ProfileUpdateState {}

final class ProfileUpdateFailure extends ProfileUpdateState {
  const ProfileUpdateFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
