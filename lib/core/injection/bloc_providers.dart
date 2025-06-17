import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/services/injection_container.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/bloc/sign_in_bloc.dart';

class BlocProviders {
  static List<BlocProvider> get all => [
    BlocProvider<SignInBloc>(create: (_) => sl<SignInBloc>()),
    // Agrega más BLoCs aquí si los necesitas
  ];
}
