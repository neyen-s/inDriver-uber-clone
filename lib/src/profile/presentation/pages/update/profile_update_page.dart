import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/core/services/loader_service.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/bloc/profile_update_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/profile_update_content.dart';

class ProfileUpdatePage extends StatefulWidget {
  const ProfileUpdatePage({super.key});

  static const routeName = '/profile-update';

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  UserEntity? user;

  @override
  Widget build(BuildContext context) {
    user = ModalRoute.of(context)?.settings.arguments as UserEntity?;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<ProfileUpdateBloc, ProfileUpdateState>(
        listener: (context, state) {
          if (state is ProfileUpdateSubmitting) {
            LoadingService.show(context, message: 'Updating profile...');
          } else {
            LoadingService.hide(context);
          }
          if (state is ProfileUpdateSuccess) {
            Navigator.pop(context, true);
          }
          if (state is ProfileUpdateFailure) {
            debugPrint('*** ProfileUpdateFailure ERROR: ${state.message} ***');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'An error occurred while updating your profile,'
                  ' try again later',
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return ProfileUpdateContent(user: user, state: state);
        },
      ),
    );
  }
}
