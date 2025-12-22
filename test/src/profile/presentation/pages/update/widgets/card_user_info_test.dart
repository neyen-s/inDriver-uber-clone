import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/card_user_info.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/image_picker_button.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/network_avatar.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/profile_textfield.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  testWidgets('renders ProfileUpdateContent with required widgets', (
    tester,
  ) async {
    await tester.pumpWidget(
      makeWidgetTestApp(
        child: ProfileInfoCard(
          user: null,
          imageFile: null,
          nameController: TextEditingController(),
          lastNameController: TextEditingController(),
          phoneController: TextEditingController(),
          nameFocus: FocusNode(),
          lastNameFocus: FocusNode(),
          phoneFocus: FocusNode(),
          onNameChanged: (_) {},
          onLastnameChanged: (_) {},
          onPhoneChanged: (_) {},
          onImagePicked: () async {},
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(ProfileTextField), findsNWidgets(3));
    expect(find.byType(ImagePickerButton), findsOneWidget);
  });

  testWidgets('shows NetworkAvatar when imageFile is null', (tester) async {
    final user = const UserEntity.empty().copyWith(image: 'http://image.jpg');

    await tester.pumpWidget(
      makeWidgetTestApp(
        child: ProfileInfoCard(
          user: user,
          imageFile: null,
          nameController: TextEditingController(),
          lastNameController: TextEditingController(),
          phoneController: TextEditingController(),
          nameFocus: FocusNode(),
          lastNameFocus: FocusNode(),
          phoneFocus: FocusNode(),
          onNameChanged: (_) {},
          onLastnameChanged: (_) {},
          onPhoneChanged: (_) {},
          onImagePicked: () async {},
        ),
      ),
    );

    expect(find.byType(NetworkAvatar), findsOneWidget);
  });

  testWidgets('calls onNameChanged when focus is lost', (tester) async {
    String? received;

    final focus = FocusNode();
    final controller = TextEditingController(text: 'John');

    await tester.pumpWidget(
      makeWidgetTestApp(
        child: ProfileInfoCard(
          user: null,
          imageFile: null,
          nameController: controller,
          lastNameController: TextEditingController(),
          phoneController: TextEditingController(),
          nameFocus: focus,
          lastNameFocus: FocusNode(),
          phoneFocus: FocusNode(),
          onNameChanged: (v) => received = v,
          onLastnameChanged: (_) {},
          onPhoneChanged: (_) {},
          onImagePicked: () async {},
        ),
      ),
    );

    focus.requestFocus();
    await tester.pump();
    focus.unfocus();
    await tester.pump();

    expect(received, 'John');
  });

  testWidgets('shows error messages when provided', (tester) async {
    await tester.pumpWidget(
      makeWidgetTestApp(
        child: ProfileInfoCard(
          user: null,
          imageFile: null,
          nameController: TextEditingController(),
          lastNameController: TextEditingController(),
          phoneController: TextEditingController(),
          nameFocus: FocusNode(),
          lastNameFocus: FocusNode(),
          phoneFocus: FocusNode(),
          nameError: 'Invalid name',
          lastnameError: 'Invalid lastname',
          phoneError: 'Invalid phone',
          onNameChanged: (_) {},
          onLastnameChanged: (_) {},
          onPhoneChanged: (_) {},
          onImagePicked: () async {},
        ),
      ),
    );

    expect(find.text('Invalid name'), findsOneWidget);
    expect(find.text('Invalid lastname'), findsOneWidget);
    expect(find.text('Invalid phone'), findsOneWidget);
  });
}
