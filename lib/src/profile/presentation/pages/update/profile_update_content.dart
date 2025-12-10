// lib/src/profile/presentation/pages/update/profile_update_content.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_icon_back.dart';
import 'package:indriver_uber_clone/core/common/widgets/sync_controller.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/core/services/loader_service.dart';
import 'package:indriver_uber_clone/core/utils/core_utils.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/bloc/profile_update_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/action_profile.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/card_user_info.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/header_profile.dart';

class ProfileUpdateContent extends StatefulWidget {
  const ProfileUpdateContent({required this.user, super.key});

  final UserEntity? user;

  @override
  State<ProfileUpdateContent> createState() => _ProfileUpdateContentState();
}

class _ProfileUpdateContentState extends State<ProfileUpdateContent> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  bool _hasInitialized = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();

    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus) {
        context.read<ProfileUpdateBloc>().add(
          ProfileUpdateNameChanged(_nameController.text),
        );
      }
    });

    _lastNameFocus.addListener(() {
      if (!_lastNameFocus.hasFocus) {
        context.read<ProfileUpdateBloc>().add(
          ProfileUpdateLastnameChanged(_lastNameController.text),
        );
      }
    });

    _phoneFocus.addListener(() {
      if (!_phoneFocus.hasFocus) {
        context.read<ProfileUpdateBloc>().add(
          ProfilePhoneChanged(_phoneController.text),
        );
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();

    _nameFocus.dispose();
    _lastNameFocus.dispose();
    _phoneFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileUpdateBloc, ProfileUpdateState>(
      listenWhen: (previous, current) {
        // listen when submission status or error or inputs change (if you want)
        return previous.isLoading != current.isLoading ||
            previous.updateSuccess != current.updateSuccess ||
            previous.errorMessage != current.errorMessage;
      },
      listener: (context, state) {
        // loader
        if (state.isLoading) {
          LoadingService.show(context, message: 'Updating profile...');
        } else {
          LoadingService.hide(context);
        }

        if (state.updateSuccess) {
          CoreUtils.showSnackBar(context, 'Profile updated successfully!');
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        // Initialization from incoming user only once
        if (!_hasInitialized && widget.user != null) {
          _nameController.text = widget.user!.name;
          _lastNameController.text = widget.user!.lastname;
          _phoneController.text = widget.user!.phone;

          // also initialize bloc inputs
          context.read<ProfileUpdateBloc>()
            ..add(ProfileUpdateNameChanged(widget.user!.name))
            ..add(ProfileUpdateLastnameChanged(widget.user!.lastname))
            ..add(ProfilePhoneChanged(widget.user!.phone));

          _hasInitialized = true;
        }

        // sync controllers with state values
        //(but avoid overwrite while focused)
        if (!_nameFocus.hasFocus) {
          syncController(_nameController, state.name.value);
        }
        if (!_lastNameFocus.hasFocus) {
          syncController(_lastNameController, state.lastname.value);
        }
        if (!_phoneFocus.hasFocus) {
          syncController(_phoneController, state.phone.value);
        }

        return Stack(
          children: [
            Column(
              children: [
                const HeaderProfile(),
                const Spacer(),
                ActionProfile(
                  onConfirm: _onConfirmSubmit,
                  option: 'UPDATE PROFILE',
                  icon: Icons.check,
                ),
                SizedBox(height: 20.h),
              ],
            ),
            ProfileInfoCard(
              user: widget.user,
              imageFile: _imageFile,
              nameController: _nameController,
              lastNameController: _lastNameController,
              phoneController: _phoneController,
              nameFocus: _nameFocus,
              lastNameFocus: _lastNameFocus,
              phoneFocus: _phoneFocus,
              onImagePicked: onImagePicked,
              onNameChanged: (val) => context.read<ProfileUpdateBloc>().add(
                ProfileUpdateNameChanged(val),
              ),
              onLastnameChanged: (val) => context.read<ProfileUpdateBloc>().add(
                ProfileUpdateLastnameChanged(val),
              ),
              onPhoneChanged: (val) => context.read<ProfileUpdateBloc>().add(
                ProfilePhoneChanged(val),
              ),
              // Pass error strings derived from inputs:
              nameError: (!state.name.isPure && state.name.isInvalid)
                  ? state.name.error
                  : null,
              lastnameError:
                  (!state.lastname.isPure && state.lastname.isInvalid)
                  ? state.lastname.error
                  : null,
              phoneError: (!state.phone.isPure && state.phone.isInvalid)
                  ? state.phone.error
                  : null,
            ),
            DefaultIconBack(
              margin: EdgeInsets.only(top: 30.h, left: 20.w),
            ),
          ],
        );
      },
    );
  }

  Future<void> onImagePicked() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final image = File(picked.path);
      setState(() => _imageFile = image);
      if (!mounted) return;
      context.read<ProfileUpdateBloc>().add(ProfileImageChanged(image));
    }
  }

  Future<void> _onConfirmSubmit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm changes'),
        content: const Text('Are you sure you want to update your profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    _nameFocus.unfocus();
    _lastNameFocus.unfocus();
    _phoneFocus.unfocus();

    if (!mounted) return;

    if (confirm ?? false) {
      context.read<ProfileUpdateBloc>().add(const SubmitProfileChanges());
    }
  }
}
