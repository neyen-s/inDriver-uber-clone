import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/services/injection_container.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/bloc/sign_in_bloc.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-up/bloc/sign_up_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/bloc/client_home_bloc.dart';

class BlocProviders {
  static List<BlocProvider> get all => [
    BlocProvider<SignInBloc>(create: (_) => sl<SignInBloc>()),
    BlocProvider<SignUpBloc>(create: (_) => sl<SignUpBloc>()),
    BlocProvider<ClientHomeBloc>(create: (_) => sl<ClientHomeBloc>()),
    // Agrega más BLoCs aquí si los necesitas
  ];
}
