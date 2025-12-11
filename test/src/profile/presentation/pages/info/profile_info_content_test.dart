import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/info/bloc/profile_info_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/info/profile_info_content.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/profile_update_page.dart';

class FakeProfileInfoEvent extends Fake implements ProfileInfoEvent {}

class FakeProfileInfoState extends Fake implements ProfileInfoState {}

class MockProfileInfoBloc extends MockBloc<ProfileInfoEvent, ProfileInfoState>
    implements ProfileInfoBloc {}

void main() {
  Widget createTestWidget({
    required Widget child,
    Map<String, WidgetBuilder>? routes,
  }) {
    return ScreenUtilInit(
      builder: (_, _) {
        return MaterialApp(
          home: Scaffold(body: child),
          routes: routes ?? {},
        );
      },
    );
  }

  testWidgets('ProfileInfoContent renders correctly and navigates', (
    tester,
  ) async {
    // Arrange
    var callbackCalled = false;
    final user = const UserEntity.empty().copyWith(
      name: 'John',
      lastname: 'Doe',
      email: 'john@example.com',
      phone: '+123456789',
    );

    await tester.pumpWidget(
      createTestWidget(
        child: ProfileInfoContent(
          user: user,
          onProfileUpdated: () => callbackCalled = true,
        ),
        routes: {
          ProfileUpdatePage.routeName: (context) =>
              const Scaffold(body: Center(child: Text('Profile Update Page'))),
        },
      ),
    );

    await tester.pumpAndSettle();

    // Assert UI elements
    expect(find.text('User profile'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('john@example.com'), findsOneWidget);
    expect(find.text('+123456789'), findsOneWidget);
    expect(find.text('Edit profile'), findsOneWidget);

    // Act: tap on edit profile
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();

    // Assert navigation
    expect(find.text('Profile Update Page'), findsOneWidget);

    // Simulate returning true from Navigator
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pop(true); // simula el retorno de true
    await tester.pumpAndSettle();

    // Assert callback called
    expect(callbackCalled, isTrue);
  });
}
