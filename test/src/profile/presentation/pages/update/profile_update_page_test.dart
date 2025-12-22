import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/auth_response_entity.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/bloc/profile_update_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/profile_update_content.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/profile_update_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/test_app.dart';

class FakeUpdateProfileInfoEvent extends Fake implements ProfileUpdateEvent {}

class FakeUpdateProfileInfoState extends Fake implements ProfileUpdateState {}

class MockUpdateProfileInfoBloc
    extends MockBloc<ProfileUpdateEvent, ProfileUpdateState>
    implements ProfileUpdateBloc {}

void main() {
  final tAuthResponseEntity = AuthResponseEntity.empty();

  setUpAll(() {
    registerFallbackValue(FakeUpdateProfileInfoEvent());
    registerFallbackValue(FakeUpdateProfileInfoState());
    registerFallbackValue(tAuthResponseEntity);
  });
  late MockUpdateProfileInfoBloc mockBloc;

  setUp(() {
    mockBloc = MockUpdateProfileInfoBloc();
  });

  testWidgets('shows loader dialog when ProfileInfoLoading is emitted', (
    tester,
  ) async {
    const initial = ProfileUpdateState();
    final loading = initial.copyWith(isLoading: true);

    when(() => mockBloc.state).thenReturn(initial);
    whenListen(
      mockBloc,
      Stream<ProfileUpdateState>.fromIterable([initial, loading]),
      initialState: initial,
    );

    await tester.pumpWidget(
      makeTestApp(
        child: const ProfileUpdatePage(),
        blocProviders: [BlocProvider<ProfileUpdateBloc>.value(value: mockBloc)],
      ),
    );

    await tester.pump();

    // assert
    expect(find.text('Updating profile...'), findsOneWidget);
  });

  testWidgets('Shows Profile content when profileInfoLoaded is emitted', (
    tester,
  ) async {
    const initial = ProfileUpdateState();
    final success = initial.copyWith(updateSuccess: true);

    when(() => mockBloc.state).thenReturn(initial);

    whenListen(
      mockBloc,
      Stream<ProfileUpdateState>.fromIterable([initial, success]),
      initialState: initial,
    );

    await tester.pumpWidget(
      makeTestApp(
        child: const ProfileUpdatePage(),
        blocProviders: [BlocProvider<ProfileUpdateBloc>.value(value: mockBloc)],
      ),
    );
    await tester.pump();

    expect(find.byType(ProfileUpdateContent), findsOneWidget);
  });

  testWidgets(
    'Shows error UI and retry button when ProfileInfoError is emitted',
    (tester) async {
      const initial = ProfileUpdateState();
      final error = initial.copyWith(errorMessage: 'Something went wrong...');

      when(() => mockBloc.state).thenReturn(initial);

      whenListen(
        mockBloc,
        Stream<ProfileUpdateState>.fromIterable([initial, error]),
        initialState: initial,
      );

      await tester.pumpWidget(
        makeTestApp(
          child: const ProfileUpdatePage(),
          blocProviders: [
            BlocProvider<ProfileUpdateBloc>.value(value: mockBloc),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          'An error occurred while updating your profile, try again later',
        ),
        findsOneWidget,
      );
      await tester.pump();
    },
  );
}
