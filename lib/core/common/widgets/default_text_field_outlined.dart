import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultTextFieldOutlined extends StatelessWidget {
  const DefaultTextFieldOutlined({
    required this.controller,
    this.filled = false,
    this.obscureText = false,
    this.readOnly = false,
    super.key,
    this.validator,
    this.fillColour,
    this.suffixIcon,
    this.prefixIcon,
    this.hintText,
    this.keyboardType,
    this.hintStyle,
    this.overrideValidator = false,
    this.componentMargin,
  });

  final String? Function(String?)? validator;
  final TextEditingController controller;
  final bool filled;
  final Color? fillColour;
  final bool obscureText;
  final bool readOnly;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool overrideValidator;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? componentMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: componentMargin ?? EdgeInsets.zero,
      child: TextFormField(
        controller: controller,
        validator: overrideValidator
            ? validator
            : (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return validator?.call(value);
              },
        onTapOutside: (_) {
          FocusScope.of(context).unfocus();
        },
        keyboardType: keyboardType,
        obscureText: obscureText,
        readOnly: readOnly,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 35, 161, 183),
              width: 2,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 35, 161, 183),
              width: 2,
            ),
          ),
          // overwriting the default padding helps with that puffy look
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          filled: filled,
          fillColor: fillColour,
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon != null
              ? Container(
                  margin: EdgeInsets.only(top: 10.h),
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    children: [
                      Icon(prefixIcon),
                      Container(height: 20, width: 1, color: Colors.grey),
                    ],
                  ),
                )
              : null,
          hintText: hintText,
          hintStyle:
              hintStyle ??
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
