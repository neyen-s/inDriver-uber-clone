import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/bloc/session-bloc/session_bloc.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/services/injection_container.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/bloc/sign_in_bloc.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-up/bloc/sign_up_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/driver-offers/bloc/client_driver_offers_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/cubit/map_lyfe_cycle_cubit.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/client-requests/bloc/driver_client_requests_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/info/bloc/profile_info_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/bloc/profile_update_bloc.dart';
import 'package:indriver_uber_clone/src/roles/presentation/bloc/roles_bloc.dart';

class BlocProviders {
  static List<BlocProvider> get all => [
    BlocProvider<SessionBloc>(create: (_) => sl<SessionBloc>()),
    BlocProvider<SignInBloc>(create: (_) => sl<SignInBloc>()),
    BlocProvider<SignUpBloc>(create: (_) => sl<SignUpBloc>()),
    BlocProvider<ProfileInfoBloc>(create: (_) => sl<ProfileInfoBloc>()),
    BlocProvider<ProfileUpdateBloc>(create: (_) => sl<ProfileUpdateBloc>()),
    BlocProvider<RolesBloc>(create: (_) => sl<RolesBloc>()),
    BlocProvider<SocketBloc>(create: (_) => sl<SocketBloc>()),
    BlocProvider<ClientMapSeekerBloc>(create: (_) => sl<ClientMapSeekerBloc>()),
    BlocProvider<MapLifecycleCubit>(create: (_) => sl<MapLifecycleCubit>()),
    BlocProvider<DriverClientRequestsBloc>(
      create: (_) => sl<DriverClientRequestsBloc>(),
    ),
    BlocProvider<ClientDriverOffersBloc>(
      create: (_) => sl<ClientDriverOffersBloc>(),
    ),
  ];
}
