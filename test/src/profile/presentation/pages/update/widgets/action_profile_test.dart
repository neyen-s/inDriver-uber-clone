import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/action_profile.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  testWidgets('action profile loads correctly', (tester) async {
    await tester.pumpWidget(
      makeWidgetTestApp(
        child: ActionProfile(
          option: 'Save',
          icon: Icons.save,
          onConfirm: () {},
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(ActionProfile), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.byIcon(Icons.save), findsOneWidget);
  });

  testWidgets('calls onConfirm when tapped', (tester) async {
    var confirmed = false;

    await tester.pumpWidget(
      makeWidgetTestApp(
        child: ActionProfile(
          option: 'Save',
          icon: Icons.save,
          onConfirm: () => confirmed = true,
        ),
      ),
    );

    await tester.tap(find.byType(ListTile));
    await tester.pump();

    expect(confirmed, isTrue);
  });
}
