//ignore lint for setting error msg to null,
// its intentional to clear previous errors
// ignore_for_file: avoid_redundant_argument_values

import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/core/utils/fold_or_emit_error.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';
import 'package:indriver_uber_clone/src/profile/domain/usecases/update_user_use_case.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/bloc/profile_update_inputs.dart';

part 'profile_update_event.dart';
part 'profile_update_state.dart';

class ProfileUpdateBloc extends Bloc<ProfileUpdateEvent, ProfileUpdateState> {
  ProfileUpdateBloc(this.updateUserUseCase, this.authUseCases)
    : super(const ProfileUpdateState()) {
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
    final name = NameInput.dirty(event.value);
    emit(state.copyWith(name: name, updateSuccess: false, errorMessage: null));
  }

  void _onLastnameChanged(
    ProfileUpdateLastnameChanged event,
    Emitter<ProfileUpdateState> emit,
  ) {
    final lastname = LastnameInput.dirty(event.value);
    emit(
      state.copyWith(
        lastname: lastname,
        updateSuccess: false,
        errorMessage: null,
      ),
    );
  }

  void _onPhoneChanged(
    ProfilePhoneChanged event,
    Emitter<ProfileUpdateState> emit,
  ) {
    final phone = PhoneInput.dirty(event.phone);
    emit(
      state.copyWith(phone: phone, updateSuccess: false, errorMessage: null),
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
    final name = NameInput.dirty(state.name.value);
    final lastname = LastnameInput.dirty(state.lastname.value);
    final phone = PhoneInput.dirty(state.phone.value);

    if (!Formz.validate([name, lastname, phone])) {
      emit(state.copyWith(name: name, lastname: lastname, phone: phone));
      return;
    }

    emit(
      state.copyWith(isLoading: true, errorMessage: null, updateSuccess: false),
    );

    try {
      final sessionEither = await authUseCases.getUserSessionUseCase();
      final session = sessionEither.fold(
        (f) => throw Exception('session not found'),
        (dto) => dto,
      );

      final updatedUser = session.user.copyWith(
        name: name.value,
        lastname: lastname.value,
        phone: phone.value,
      );

      final result = await updateUserUseCase(
        UpdateProfileParams(
          user: updatedUser,
          token: session.token,
          file: _imageFile,
        ),
      );

      final newUser = await foldOrEmitError<UserEntity, ProfileUpdateState>(
        result,
        emit,
        (msg) => state.copyWith(isLoading: false, errorMessage: msg),
      );

      if (newUser == null) return;

      await authUseCases.saveUserSessionUseCase(
        session.copyWith(user: newUser),
      );

      emit(state.copyWith(isLoading: false, updateSuccess: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
