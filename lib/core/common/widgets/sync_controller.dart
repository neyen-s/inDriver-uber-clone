import 'package:flutter/material.dart';

void syncController(TextEditingController controller, String newValue) {
  if (controller.text == newValue) return;
  final oldSelection = controller.selection;
  controller.text = newValue;
  try {
    final offset = oldSelection.baseOffset.clamp(0, newValue.length);
    controller.selection = TextSelection.collapsed(offset: offset);
  } catch (_) {
    controller.selection = TextSelection.collapsed(offset: newValue.length);
  }
}
