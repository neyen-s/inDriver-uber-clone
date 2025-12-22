import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_text_field.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/profile_textfield.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  testWidgets('profile textfield loads correctly', (tester) async {
    await tester.pumpWidget(
      makeWidgetTestApp(
        child: ProfileTextField(
          hintText: 'Enter your name',
          keyboardType: TextInputType.text,
          focusNode: FocusNode(),
          onFocusLost: () {},
          controller: TextEditingController(),
          prefixIcon: Icons.person,
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(ProfileTextField), findsOneWidget);
    expect(find.byType(DefaultTextField), findsOneWidget);
  });

  testWidgets('Listens to focus changes', (tester) async {
    final focusNode = FocusNode();
    var focusLostCalled = false;

    await tester.pumpWidget(
      makeWidgetTestApp(
        child: ProfileTextField(
          hintText: 'Enter your name',
          keyboardType: TextInputType.text,
          focusNode: focusNode,
          onFocusLost: () {
            focusLostCalled = true;
          },
          controller: TextEditingController(),
          prefixIcon: Icons.person,
        ),
      ),
    );

    // Simulate focus loss
    focusNode.requestFocus();
    await tester.pump();
    focusNode.unfocus();
    await tester.pump();

    expect(focusLostCalled, isTrue);
  });
}
