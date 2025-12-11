import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/common/widgets/dynamic_lottie_and_msg.dart';
import 'package:indriver_uber_clone/core/services/loader_service.dart';
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
      body: BlocConsumer<ProfileInfoBloc, ProfileInfoState>(
        listener: (context, state) {
          if (state is ProfileInfoLoading) {
            LoadingService.show(context, message: 'Loading profile...');
          } else {
            LoadingService.hide(context);
          }
        },
        builder: (context, state) {
          if (state is ProfileInfoLoaded) {
            final user = state.user.user;

            return ProfileInfoContent(
              user: user,
              onProfileUpdated: () {
                context.read<ProfileInfoBloc>().add(const LoadUserProfile());
              },
            );
          } else if (state is ProfileInfoError) {
            return Center(
              child: Column(
                children: [
                  DynamicLottieAndMsg(
                    message: 'Error: Something went wrong...',
                    onPressed: () {
                      context.read<ProfileInfoBloc>().add(
                        const LoadUserProfile(),
                      );
                    },
                    child: const Text(
                      'try again',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
