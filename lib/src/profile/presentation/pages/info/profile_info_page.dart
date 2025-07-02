import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/info/bloc/profile_info_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/info/profile_info_content.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({super.key});

  static const routeName = '/profile-info';

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileInfoBloc>().add(const LoadUserProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileInfoBloc, ProfileInfoState>(
        builder: (context, state) {
          if (state is ProfileInfoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileInfoLoaded) {
            final user = state.user.user;

            return ProfileInfoContent(
              user: user,
              onProfileUpdated: () {
                context.read<ProfileInfoBloc>().add(const LoadUserProfile());
              },
            );
          } else if (state is ProfileInfoError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
