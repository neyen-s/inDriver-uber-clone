import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:formz/formz.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/core/utils/fold_or_emit_error.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/last_name_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/name_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/phone_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';
import 'package:indriver_uber_clone/src/profile/domain/usecases/update_user_use_case.dart';

part 'profile_update_event.dart';
part 'profile_update_state.dart';

class ProfileUpdateBloc extends Bloc<ProfileUpdateEvent, ProfileUpdateState> {
  ProfileUpdateBloc(this.updateUserUseCase, this.authUseCases)
    : super(const ProfileUpdateInitial()) {
    on<ProfileUpdateNameChanged>(_onNameChanged);
    on<ProfileUpdateLastnameChanged>(_onLastnameChanged);
    on<ProfilePhoneChanged>(_onPhoneChanged);
    on<ProfileImageChanged>(_onImageChanged);

    on<SubmitProfileChanges>(_onSubmitChanges);
  }

  final UpdateUserUseCase updateUserUseCase;
  final AuthUseCases authUseCases;

  File? _imageFile;

  void _onNameChanged(
    ProfileUpdateNameChanged event,
    Emitter<ProfileUpdateState> emit,
  ) {
    final current = _extractInputs();
    emit(
      ProfileUpdateValidating(
        name: NameEntity.dirty(event.value),
        lastname: current.lastname,
        phone: current.phone,
      ),
    );
  }

  void _onLastnameChanged(
    ProfileUpdateLastnameChanged event,
    Emitter<ProfileUpdateState> emit,
  ) {
    final current = _extractInputs();
    emit(
      ProfileUpdateValidating(
        name: current.name,
        lastname: LastnameEntity.dirty(event.value),
        phone: current.phone,
      ),
    );
  }

  void _onPhoneChanged(
    ProfilePhoneChanged event,
    Emitter<ProfileUpdateState> emit,
  ) {
    final current = _extractInputs();
    emit(
      ProfileUpdateValidating(
        name: current.name,
        lastname: current.lastname,
        phone: PhoneEntity.dirty(event.phone),
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
    final current = _extractInputs();

    final name = NameEntity.dirty(current.name.value);
    final lastname = LastnameEntity.dirty(current.lastname.value);
    final phone = PhoneEntity.dirty(current.phone.value);

    final isValid = Formz.validate([name, lastname, phone]);
    if (!isValid) {
      emit(
        ProfileUpdateValidating(name: name, lastname: lastname, phone: phone),
      );
      return;
    }

    emit(ProfileUpdateSubmitting(name: name, lastname: lastname, phone: phone));

    try {
      final sessionResult = await authUseCases.getUserSessionUseCase();
      final session = sessionResult.fold(
        (failure) => throw Exception('Sesión no encontrada'),
        (dto) => dto,
      );

      debugPrint('SESION USER : ${session.user} ');

      final updatedUser = session.user.copyWith(
        name: name.value,
        lastname: lastname.value,
        phone: phone.value,
      );

      debugPrint(
        ' USER: $updatedUser , TOKEN: ${session.token}, FILE: $_imageFile ',
      );

      final updateResult = await updateUserUseCase(
        UpdateProfileParams(
          user: updatedUser,
          token: session.token,
          file: _imageFile,
        ),
      );

      final newUser = await foldOrEmitError<UserEntity, ProfileUpdateState>(
        updateResult,
        emit,
        ProfileUpdateFailure.new,
      );
      if (newUser == null) return;

      final newSession = session.copyWith(user: newUser);
      await authUseCases.saveUserSessionUseCase(newSession);

      emit(ProfileUpdateSuccess());
    } catch (e) {
      emit(ProfileUpdateFailure(e.toString()));
    }
  }

  _InputBundle _extractInputs() {
    return switch (state) {
      final ProfileUpdateInitial s => _InputBundle(s.name, s.lastname, s.phone),
      final ProfileUpdateValidating s => _InputBundle(
        s.name,
        s.lastname,
        s.phone,
      ),
      final ProfileUpdateSubmitting s => _InputBundle(
        s.name,
        s.lastname,
        s.phone,
      ),
      _ => _InputBundle(
        const NameEntity.pure(),
        const LastnameEntity.pure(),
        const PhoneEntity.pure(),
      ),
    };
  }
}

class _InputBundle {
  _InputBundle(this.name, this.lastname, this.phone);
  final NameEntity name;
  final LastnameEntity lastname;
  final PhoneEntity phone;
}
