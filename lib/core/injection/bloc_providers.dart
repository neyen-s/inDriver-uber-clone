import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/bloc/session-bloc/session_bloc.dart';
import 'package:indriver_uber_clone/core/services/injection_container.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/bloc/sign_in_bloc.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-up/bloc/sign_up_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/client-home/bloc/client_home_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/bloc/bloc/driver_home_bloc.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/map/bloc/driver_map_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/info/bloc/profile_info_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/bloc/profile_update_bloc.dart';
import 'package:indriver_uber_clone/src/roles/presentation/bloc/roles_bloc.dart';

class BlocProviders {
  static List<BlocProvider> get all => [
    BlocProvider<SignInBloc>(create: (_) => sl<SignInBloc>()),
    BlocProvider<SignUpBloc>(create: (_) => sl<SignUpBloc>()),
    BlocProvider<ClientHomeBloc>(create: (_) => sl<ClientHomeBloc>()),
    //BlocProvider<DriverHomeBloc>(create: (_) => sl<DriverHomeBloc>()),
    BlocProvider<ProfileInfoBloc>(create: (_) => sl<ProfileInfoBloc>()),
    BlocProvider<ProfileUpdateBloc>(create: (_) => sl<ProfileUpdateBloc>()),
    BlocProvider<SessionBloc>(create: (_) => sl<SessionBloc>()),
    BlocProvider<RolesBloc>(create: (_) => sl<RolesBloc>()),
    BlocProvider<ClientMapSeekerBloc>(create: (_) => sl<ClientMapSeekerBloc>()),
    //BlocProvider<DriverMapBloc>(create: (_) => sl<DriverMapBloc>()),
  ];
}
