import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_text_field.dart';

import 'package:indriver_uber_clone/core/extensions/context_extensions.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/car-info/bloc/driver_car_info_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/bloc/profile_update_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/action_profile.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/header_profile.dart';

typedef ProfileUpdateEventCreator = ProfileUpdateEvent Function(String);

class DriverCarInfoContent extends StatefulWidget {
  const DriverCarInfoContent({super.key});

  @override
  State<DriverCarInfoContent> createState() => _DriverCarInfoContentState();
}

class _DriverCarInfoContentState extends State<DriverCarInfoContent> {
  final _brandTextController = TextEditingController();
  final _colorTextController = TextEditingController();
  final _plateTextController = TextEditingController();

  final _brandFocus = FocusNode();
  final _colorFocus = FocusNode();
  final _plateFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _brandFocus.addListener(() {
      if (!_brandFocus.hasFocus) {
        final bloc = context.read<DriverCarInfoBloc>();
        final currentValue = bloc.state.brand.value;
        final newValue = _brandTextController.text;
        if (newValue != currentValue) {
          bloc.add(BrandChanged(newValue));
        }
      }
    });
    _colorFocus.addListener(() {
      if (!_colorFocus.hasFocus) {
        final bloc = context.read<DriverCarInfoBloc>();
        final currentValue = bloc.state.color.value;
        final newValue = _colorTextController.text;
        if (newValue != currentValue) {
          bloc.add(ColorChanged(newValue));
        }
      }
    });
    _plateFocus.addListener(() {
      if (!_plateFocus.hasFocus) {
        final bloc = context.read<DriverCarInfoBloc>();
        final currentValue = bloc.state.plate.value;
        final newValue = _plateTextController.text;
        if (newValue != currentValue) {
          bloc.add(PlateChanged(newValue));
        }
      }
    });
  }

  @override
  void dispose() {
    _brandTextController.dispose();
    _colorTextController.dispose();
    _plateTextController.dispose();

    _brandFocus.dispose();
    _colorFocus.dispose();
    _plateFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverCarInfoBloc, DriverCarInfoState>(
      listenWhen: (previous, current) {
        // Only sync controllers when incoming values actually
        // changed OR when a loading finished
        final valuesChanged =
            previous.brand.value != current.brand.value ||
            previous.color.value != current.color.value ||
            previous.plate.value != current.plate.value;

        final finishedLoading =
            previous.isLoading == true && current.isLoading == false;

        return valuesChanged || finishedLoading;
      },
      listener: (context, state) {
        if (!_brandFocus.hasFocus) {
          _brandTextController.text = state.brand.value;
          _brandTextController.selection = TextSelection.fromPosition(
            TextPosition(offset: _brandTextController.text.length),
          );
        }
        if (!_colorFocus.hasFocus) {
          _colorTextController.text = state.color.value;
          _colorTextController.selection = TextSelection.fromPosition(
            TextPosition(offset: _colorTextController.text.length),
          );
        }
        if (!_plateFocus.hasFocus) {
          _plateTextController.text = state.plate.value;
          _plateTextController.selection = TextSelection.fromPosition(
            TextPosition(offset: _plateTextController.text.length),
          );
        }
      },

      builder: (context, state) {
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

            Container(
              margin: EdgeInsets.only(top: 100.h, left: 20.w, right: 20.w),
              width: context.width,
              height: 230.h,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.only(top: 20.h),
                  child: Column(
                    children: [
                      SizedBox(height: 10.h),
                      DefaultTextField(
                        controller: _brandTextController,
                        onChanged: (v) => context.read<DriverCarInfoBloc>().add(
                          BrandChanged(v),
                        ),
                        focusNode: _brandFocus,
                        hintText: 'Brand',
                        prefixIcon: Icons.directions_car,
                        componentMargin: EdgeInsets.symmetric(horizontal: 20.w),
                        filled: true,
                        fillColour: Colors.grey[200],
                        errorText:
                            (state.brand.value.isNotEmpty ||
                                    state.hasSubmitted) &&
                                state.brand.isInvalid
                            ? state.brand.error
                            : null,
                      ),
                      SizedBox(height: 10.h),
                      DefaultTextField(
                        controller: _colorTextController,
                        onChanged: (v) => context.read<DriverCarInfoBloc>().add(
                          ColorChanged(v),
                        ),
                        focusNode: _colorFocus,
                        hintText: 'Car Color',
                        prefixIcon: Icons.format_paint,
                        componentMargin: EdgeInsets.symmetric(horizontal: 20.w),
                        filled: true,
                        fillColour: Colors.grey[200],
                        errorText:
                            ((state.color.value.isNotEmpty) ||
                                    state.hasSubmitted == true) &&
                                state.color.isInvalid
                            ? state.color.error
                            : null,
                      ),
                      SizedBox(height: 10.h),
                      DefaultTextField(
                        controller: _plateTextController,
                        onChanged: (v) => context.read<DriverCarInfoBloc>().add(
                          PlateChanged(v),
                        ),
                        focusNode: _plateFocus,
                        hintText: 'Plate',
                        filled: true,
                        fillColour: Colors.grey[200],
                        prefixIcon: Icons.confirmation_number,
                        componentMargin: EdgeInsets.symmetric(horizontal: 20.w),
                        errorText:
                            ((state.plate.value.isNotEmpty) ||
                                    state.hasSubmitted == true) &&
                                state.plate.isInvalid
                            ? state.plate.error
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
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

    _brandFocus.unfocus();
    _colorFocus.unfocus();
    _plateFocus.unfocus();

    if (!mounted) return;

    if (confirm ?? false) {
      context.read<DriverCarInfoBloc>().add(SubmitCarChanges());
    }
  }
}
