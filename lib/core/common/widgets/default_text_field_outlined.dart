import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultTextFieldOutlined extends StatelessWidget {
  const DefaultTextFieldOutlined({
    this.initialValue,
    this.controller,
    this.onChanged,
    this.errorText,
    this.filled = false,
    this.obscureText = false,
    this.readOnly = false,
    super.key,
    this.fillColour,
    this.suffixIcon,
    this.prefixIcon,
    this.hintText,
    this.keyboardType,
    this.hintStyle,
    this.componentMargin,
  });

  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool filled;
  final Color? fillColour;
  final bool obscureText;
  final bool readOnly;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? componentMargin;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: componentMargin ?? EdgeInsets.zero,
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        keyboardType: keyboardType,
        obscureText: obscureText,
        readOnly: readOnly,
        controller: controller,
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
                      Icon(prefixIcon, color: Colors.white),
                      Container(height: 20, width: 1, color: Colors.white),
                    ],
                  ),
                )
              : null,
          hintText: hintText,
          hintStyle:
              hintStyle ??
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          errorText: errorText,
        ),
      ),
    );
  }
}
