import 'package:indriver_uber_clone/src/auth/domain/usecase/get_user_session_use_case.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/save_user_session_use_case.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/sign_in_use_case.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/sign_up_use_case.dart';

class AuthUseCases {
  AuthUseCases({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.getUserSessionUseCase,
    required this.saveUserSessionUseCase,
  });
  SignInUseCase signInUseCase;
  SignUpUseCase signUpUseCase;
  GetUserSessionUseCase getUserSessionUseCase;
  SaveUserSessionUseCase saveUserSessionUseCase;
}
