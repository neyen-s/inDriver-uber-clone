import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/core/domain/usecases/socket/socket_use_cases.dart';
import 'package:indriver_uber_clone/core/utils/base_use_cases.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/auth/domain/repository/auth_repository.dart';

class SignOutUseCase extends UsecaseWithoutParams<void> {
  const SignOutUseCase({
    required this.authRepository,
    required this.socketUseCases,
  });

  final AuthRepository authRepository;
  final SocketUseCases socketUseCases;

  @override
  ResultFuture<void> call() async {
    try {
      await socketUseCases.disconnectSocketUseCase();
    } catch (e) {
      debugPrint('SignOutUseCase: socket disconnect failed: $e');
    }

    return authRepository.signOut();
  }
}
