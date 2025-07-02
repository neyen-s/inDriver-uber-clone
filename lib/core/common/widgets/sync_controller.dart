import 'package:flutter/material.dart';

void syncController(TextEditingController controller, String newValue) {
  if (controller.text != newValue) {
    controller.value = TextEditingValue(
      text: newValue,
      selection: TextSelection.collapsed(offset: newValue.length),
    );
  }
}
