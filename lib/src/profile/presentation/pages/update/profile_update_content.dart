import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_icon_back.dart';

import 'package:indriver_uber_clone/core/common/widgets/sync_controller.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/bloc/profile_update_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/viewmodels/profile_update_view_model.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/action_profile.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/card_user_info.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/header_profile.dart';

typedef ProfileUpdateEventCreator = ProfileUpdateEvent Function(String);

class ProfileUpdateContent extends StatefulWidget {
  const ProfileUpdateContent({
    required this.user,
    required this.state,
    super.key,
  });

  final UserEntity? user;
  final ProfileUpdateState state;

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
      _onFocusLost(
        _nameFocus,
        _nameController.text,
        ProfileUpdateNameChanged.new,
      );
    });

    _lastNameFocus.addListener(() {
      _onFocusLost(
        _lastNameFocus,
        _lastNameController.text,
        ProfileUpdateLastnameChanged.new,
      );
    });

    _phoneFocus.addListener(() {
      _onFocusLost(_phoneFocus, _phoneController.text, ProfilePhoneChanged.new);
    });
  }

  void _onFocusLost(
    FocusNode node,
    String value,
    ProfileUpdateEventCreator eventCreator,
  ) {
    if (!node.hasFocus) {
      final event = eventCreator(value);
      context.read<ProfileUpdateBloc>().add(event);
    }
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
    if (!_hasInitialized && widget.user != null) {
      _nameController.text = widget.user!.name;
      _lastNameController.text = widget.user!.lastname;
      _phoneController.text = widget.user!.phone;

      context.read<ProfileUpdateBloc>()
        ..add(ProfileUpdateNameChanged(widget.user!.name))
        ..add(ProfileUpdateLastnameChanged(widget.user!.lastname))
        ..add(ProfilePhoneChanged(widget.user!.phone));

      _hasInitialized = true;
    }

    final vm = ProfileUpdateViewModel.fromState(widget.state);

    syncController(_nameController, vm.name.value);
    syncController(_lastNameController, vm.lastname.value);
    syncController(_phoneController, vm.phone.value);

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
        CardUserInfo(
          vm: vm,
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
          onPhoneChanged: (val) =>
              context.read<ProfileUpdateBloc>().add(ProfilePhoneChanged(val)),
        ),
        DefaultIconBack(
          margin: EdgeInsets.only(top: 30.h, left: 20.w),
        ),
      ],
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
