import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/network_avatar.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  testWidgets('network avatar normalices url and renders correctly', (
    tester,
  ) async {
    await tester.pumpWidget(
      makeWidgetTestApp(
        child: const NetworkAvatar(
          imageUrl: 'http://example.com//path///to////image.jpg',
        ),
      ),
    );

    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is NetworkImage,
      ),
      findsOneWidget,
    );
  });
  testWidgets('network avatar fails to normalice url and renders ', (
    tester,
  ) async {
    await tester.pumpWidget(
      makeWidgetTestApp(child: const NetworkAvatar(imageUrl: ' invalid_url')),
    );

    await tester.pump();

    expect(find.byType(NetworkAvatar), findsOneWidget);
    expect(find.byType(ClipOval), findsOneWidget);
  });
}
