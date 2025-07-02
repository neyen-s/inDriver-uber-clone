import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/last_name_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/name_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/phone_entity.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/bloc/profile_update_bloc.dart';

class ProfileUpdateViewModel {
  ProfileUpdateViewModel({
    required this.name,
    required this.lastname,
    required this.phone,
    required this.isValid,
    required this.isSubmitting,
  });

  factory ProfileUpdateViewModel.fromState(ProfileUpdateState state) {
    return ProfileUpdateViewModel(
      name: state.name,
      lastname: state.lastname,
      phone: state.phone,
      isValid: state.isValid,
      isSubmitting: state is ProfileUpdateSubmitting,
    );
  }
  final NameEntity name;
  final LastnameEntity lastname;
  final PhoneEntity phone;
  final bool isValid;
  final bool isSubmitting;
}
