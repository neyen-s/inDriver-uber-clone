import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';

Future<T?> foldOrEmitError<T, S>(
  Either<Failure, T> result,
  Emitter<S> emit,
  S Function(String message) onError,
) async {
  return await result.fold((failure) async {
    emit(onError(failure.message));
    return null;
  }, (value) async => value);
}
