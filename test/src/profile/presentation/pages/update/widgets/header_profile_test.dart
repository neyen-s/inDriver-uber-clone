import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/header_profile.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  testWidgets('Renders HeaderProfile with correct texts', (tester) async {
    await tester.pumpWidget(makeWidgetTestApp(child: const HeaderProfile()));
    await tester.pump();
    expect(find.text('EDIT PROFILE'), findsOneWidget);
  });
}
