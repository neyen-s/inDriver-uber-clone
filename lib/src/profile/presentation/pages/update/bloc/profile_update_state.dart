part of 'profile_update_bloc.dart';

sealed class ProfileUpdateState extends Equatable {
  const ProfileUpdateState({
    required this.name,
    required this.lastname,
    required this.phone,
    required this.isValid,
  });
  final NameEntity name;
  final LastnameEntity lastname;
  final PhoneEntity phone;
  final bool isValid;

  @override
  List<Object?> get props => [name, lastname, phone, isValid];
}

final class ProfileUpdateInitial extends ProfileUpdateState {
  const ProfileUpdateInitial({
    super.name = const NameEntity.pure(),
    super.lastname = const LastnameEntity.pure(),
    super.phone = const PhoneEntity.pure(),
  }) : super(isValid: false);
}

final class ProfileUpdateValidating extends ProfileUpdateState {
  const ProfileUpdateValidating({
    required super.name,
    required super.lastname,
    required super.phone,
    required super.isValid,
  });
}

final class ProfileUpdateSubmitting extends ProfileUpdateState {
  const ProfileUpdateSubmitting({
    required super.name,
    required super.lastname,
    required super.phone,
    required super.isValid,
  });
}

final class ProfileUpdateSuccess extends ProfileUpdateState {
  const ProfileUpdateSuccess()
    : super(
        name: const NameEntity.pure(),
        lastname: const LastnameEntity.pure(),
        phone: const PhoneEntity.pure(),
        isValid: false,
      );
}

final class ProfileUpdateError extends ProfileUpdateState {
  const ProfileUpdateError({
    required this.message,
    required super.name,
    required super.lastname,
    required super.phone,
    required super.isValid,
  });
  final String message;

  @override
  List<Object?> get props => super.props..add(message);
}
