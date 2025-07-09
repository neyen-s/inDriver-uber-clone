import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/core/extensions/context_extensions.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/viewmodels/profile_update_view_model.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/image_picker_button.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/profile_textfield.dart';

class CardUserInfo extends StatelessWidget {
  const CardUserInfo({
    required this.vm,
    required this.user,
    required this.imageFile,
    required this.nameController,
    required this.lastNameController,
    required this.phoneController,
    required this.nameFocus,
    required this.lastNameFocus,
    required this.phoneFocus,
    required this.onNameChanged,
    required this.onLastnameChanged,
    required this.onPhoneChanged,
    required this.onImagePicked,
    super.key,
  });

  final ProfileUpdateViewModel vm;
  final UserEntity? user;
  final File? imageFile;

  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;

  final FocusNode nameFocus;
  final FocusNode lastNameFocus;
  final FocusNode phoneFocus;

  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onLastnameChanged;
  final ValueChanged<String> onPhoneChanged;

  final Future<void> Function() onImagePicked;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 100.h, left: 20.w, right: 20.w),
      width: context.width,
      height: 300.h,
      child: Card(
        //margin: EdgeInsets.only(top: 20.h),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: Column(
            children: [
              SizedBox(
                width: 100.w,
                height: 100.w,
                child: Stack(
                  children: [
                    SizedBox.expand(
                      child: ClipOval(
                        child: imageFile != null
                            ? Image.file(imageFile!, fit: BoxFit.cover)
                            : FadeInImage.assetNetwork(
                                placeholder: 'assets/img/user.png',
                                image: user?.image ?? '',
                                fit: BoxFit.cover,
                                imageErrorBuilder: (_, _, _) =>
                                    Image.asset('assets/img/user.png'),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: ImagePickerButton(onTap: onImagePicked),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              ProfileTextField(
                controller: nameController,
                focusNode: nameFocus,
                hintText: 'Name',
                prefixIcon: Icons.person,
                errorText: !vm.name.isPure && vm.name.isNotValid
                    ? vm.name.error?.toString()
                    : null,
                onFocusLost: () => onNameChanged(nameController.text),
              ),
              SizedBox(height: 10.h),
              ProfileTextField(
                controller: lastNameController,
                focusNode: lastNameFocus,
                hintText: 'Last name',
                prefixIcon: Icons.person_outline,
                errorText: !vm.lastname.isPure && vm.lastname.isNotValid
                    ? vm.lastname.error?.toString()
                    : null,
                onFocusLost: () => onLastnameChanged(lastNameController.text),
              ),
              SizedBox(height: 10.h),
              ProfileTextField(
                controller: phoneController,
                focusNode: phoneFocus,
                hintText: 'Phone',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                errorText: !vm.phone.isPure && vm.phone.isNotValid
                    ? vm.phone.error?.toString()
                    : null,
                onFocusLost: () => onPhoneChanged(phoneController.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
