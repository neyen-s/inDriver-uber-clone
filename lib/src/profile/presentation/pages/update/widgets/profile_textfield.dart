import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_text_field.dart';

class ProfileTextField extends StatefulWidget {
  const ProfileTextField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.prefixIcon,
    required this.onFocusLost,
    this.errorText,
    this.keyboardType,
    super.key,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final IconData prefixIcon;
  final String? errorText;
  final TextInputType? keyboardType;
  final VoidCallback onFocusLost;

  @override
  State<ProfileTextField> createState() => _ProfileTextFieldState();
}

class _ProfileTextFieldState extends State<ProfileTextField> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!widget.focusNode.hasFocus) {
      widget.onFocusLost();
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      hintText: widget.hintText,
      prefixIcon: widget.prefixIcon,
      filled: true,
      fillColour: Colors.grey[200],
      componentMargin: EdgeInsets.symmetric(horizontal: 20.w),
      keyboardType: widget.keyboardType,
      errorText: widget.errorText,
    );
  }
}
