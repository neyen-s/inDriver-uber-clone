part of 'profile_update_bloc.dart';

class ProfileUpdateState extends Equatable {
  const ProfileUpdateState({
    this.name = const NameInput.pure(),
    this.lastname = const LastnameInput.pure(),
    this.phone = const PhoneInput.pure(),
    this.isLoading = false,
    this.updateSuccess = false,
    this.errorMessage,
  });

  final NameInput name;
  final LastnameInput lastname;
  final PhoneInput phone;
  final bool isLoading;
  final bool updateSuccess;
  final String? errorMessage;

  bool get isValid => Formz.validate([name, lastname, phone]);

  ProfileUpdateState copyWith({
    NameInput? name,
    LastnameInput? lastname,
    PhoneInput? phone,
    bool? isLoading,
    bool? updateSuccess,
    String? errorMessage,
  }) {
    return ProfileUpdateState(
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      phone: phone ?? this.phone,
      isLoading: isLoading ?? this.isLoading,
      updateSuccess: updateSuccess ?? this.updateSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    name,
    lastname,
    phone,
    isLoading,
    updateSuccess,
    errorMessage,
  ];
}
