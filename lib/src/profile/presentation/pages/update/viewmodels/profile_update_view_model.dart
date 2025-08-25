import 'package:formz/formz.dart';
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
    NameEntity name;
    LastnameEntity lastname;
    PhoneEntity phone;
    var isSubmitting = false;

    if (state is ProfileUpdateInitial) {
      name = state.name;
      lastname = state.lastname;
      phone = state.phone;
    } else if (state is ProfileUpdateValidating) {
      name = state.name;
      lastname = state.lastname;
      phone = state.phone;
    } else if (state is ProfileUpdateSubmitting) {
      name = state.name;
      lastname = state.lastname;
      phone = state.phone;
      isSubmitting = true;
    } else if (state is ProfileUpdateFailure) {
      name = const NameEntity.pure();
      lastname = const LastnameEntity.pure();
      phone = const PhoneEntity.pure();
    } else {
      name = const NameEntity.pure();
      lastname = const LastnameEntity.pure();
      phone = const PhoneEntity.pure();
    }

    final isValid = Formz.validate([name, lastname, phone]);

    return ProfileUpdateViewModel(
      name: name,
      lastname: lastname,
      phone: phone,
      isValid: isValid,
      isSubmitting: isSubmitting,
    );
  }

  final NameEntity name;
  final LastnameEntity lastname;
  final PhoneEntity phone;
  final bool isValid;
  final bool isSubmitting;
}
