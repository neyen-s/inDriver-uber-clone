import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/image_picker_button.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  testWidgets('Renders ImagePickerButton', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      makeWidgetTestApp(child: ImagePickerButton(onTap: () => tapped = true)),
    );
    await tester.tap(find.byType(ImagePickerButton));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
