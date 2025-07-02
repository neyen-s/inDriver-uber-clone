import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/last_name_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/name_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/phone_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/repository/auth_repository.dart';
import 'package:indriver_uber_clone/src/profile/domain/usecases/update_user_use_case.dart';

part 'profile_update_event.dart';
part 'profile_update_state.dart';

class ProfileUpdateBloc extends Bloc<ProfileUpdateEvent, ProfileUpdateState> {
  ProfileUpdateBloc(this.updateUserUseCase, this.authRepository)
    : super(const ProfileUpdateInitial()) {
    on<ProfileNameChanged>(_onNameChanged);
    on<ProfileLastnameChanged>(_onLastnameChanged);
    on<ProfilePhoneChanged>(_onPhoneChanged);
    on<ProfileImageChanged>(_onImageChanged);

    on<SubmitProfileChanges>(_onSubmitChanges);
  }

  final UpdateUserUseCase updateUserUseCase;
  final AuthRepository authRepository;
  File? _imageFile;

  void _onNameChanged(
    ProfileNameChanged event,
    Emitter<ProfileUpdateState> emit,
  ) {
    final name = NameEntity.dirty(event.name);
    final isValid = Formz.validate([name, state.lastname, state.phone]);

    emit(
      ProfileUpdateValidating(
        name: name,
        lastname: state.lastname,
        phone: state.phone,
        isValid: isValid,
      ),
    );
  }

  void _onLastnameChanged(
    ProfileLastnameChanged event,
    Emitter<ProfileUpdateState> emit,
  ) {
    final lastname = LastnameEntity.dirty(event.lastname);
    final isValid = Formz.validate([state.name, lastname, state.phone]);

    emit(
      ProfileUpdateValidating(
        name: state.name,
        lastname: lastname,
        phone: state.phone,
        isValid: isValid,
      ),
    );
  }

  void _onPhoneChanged(
    ProfilePhoneChanged event,
    Emitter<ProfileUpdateState> emit,
  ) {
    final phone = PhoneEntity.dirty(event.phone);
    final isValid = Formz.validate([state.name, state.lastname, phone]);

    emit(
      ProfileUpdateValidating(
        name: state.name,
        lastname: state.lastname,
        phone: phone,
        isValid: isValid,
      ),
    );
  }

  void _onImageChanged(
    ProfileImageChanged event,
    Emitter<ProfileUpdateState> emit,
  ) {
    _imageFile = event.image;
  }

  Future<void> _onSubmitChanges(
    SubmitProfileChanges event,
    Emitter<ProfileUpdateState> emit,
  ) async {
    final name = NameEntity.dirty(state.name.value);
    final lastname = LastnameEntity.dirty(state.lastname.value);
    final phone = PhoneEntity.dirty(state.phone.value);
    final isValid = Formz.validate([name, lastname, phone]);
    print(
      'isValid $isValid name ${name.value} lastname ${lastname.value} phone ${phone.value}',
    );
    emit(
      ProfileUpdateValidating(
        name: name,
        lastname: lastname,
        phone: phone,
        isValid: isValid,
      ),
    );

    if (!isValid) return;

    emit(
      ProfileUpdateSubmitting(
        name: name,
        lastname: lastname,
        phone: phone,
        isValid: true,
      ),
    );

    try {
      final sessionResult = await authRepository.getUserSession();
      final session = sessionResult.fold(
        (failure) => throw Exception('Sesión no encontrada'),
        (dto) => dto,
      );
      print('session ${session.user}');

      final updatedUser = session.user.copyWith(
        name: name.value,
        lastname: lastname.value,
        phone: phone.value,
      );

      print('updatedUser $updatedUser');

      final result = await updateUserUseCase(
        UpdateProfileParams(
          user: updatedUser,
          token: session.token,
          file: _imageFile,
        ),
      );

      print('result $result');

      await result.fold(
        (failure) async => emit(
          ProfileUpdateError(
            message: failure.message,
            name: name,
            lastname: lastname,
            phone: phone,
            isValid: true,
          ),
        ),
        (user) async {
          await authRepository.saveUserSession(session.copyWith(user: user));
          emit(const ProfileUpdateSuccess());
        },
      );
    } catch (e) {
      emit(
        ProfileUpdateError(
          message: e.toString(),
          name: name,
          lastname: lastname,
          phone: phone,
          isValid: true,
        ),
      );
    }
  }
}
