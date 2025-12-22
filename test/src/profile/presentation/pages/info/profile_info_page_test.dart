import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/auth_response_entity.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/info/bloc/profile_info_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/info/profile_info_content.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/info/profile_info_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/test_app.dart';

class FakeProfileInfoEvent extends Fake implements ProfileInfoEvent {}

class FakeProfileInfoState extends Fake implements ProfileInfoState {}

class MockProfileInfoBloc extends MockBloc<ProfileInfoEvent, ProfileInfoState>
    implements ProfileInfoBloc {}

void main() {
  final tAuthResponseEntity = AuthResponseEntity.empty();

  setUpAll(() {
    registerFallbackValue(FakeProfileInfoEvent());
    registerFallbackValue(FakeProfileInfoState());
    registerFallbackValue(tAuthResponseEntity);
  });

  late MockProfileInfoBloc mockBloc;

  setUp(() {
    mockBloc = MockProfileInfoBloc();
  });

  testWidgets('shows loader dialog when ProfileInfoLoading is emitted', (
    tester,
  ) async {
    const initial = ProfileInfoState();
    const loading = ProfileInfoLoading();

    when(() => mockBloc.state).thenReturn(initial);
    whenListen(
      mockBloc,
      Stream<ProfileInfoState>.fromIterable([initial, loading]),
      initialState: initial,
    );

    await tester.pumpWidget(
      makeTestApp(
        child: const ProfileInfoPage(),
        blocProviders: [BlocProvider<ProfileInfoBloc>.value(value: mockBloc)],
      ),
    );

    await tester.pump();

    // assert
    expect(find.text('Loading profile...'), findsOneWidget);
  });

  testWidgets('Shows Profile content when profileInfoLoaded is emitted', (
    tester,
  ) async {
    const initial = ProfileInfoInitial();
    final loaded = ProfileInfoLoaded(tAuthResponseEntity);

    when(() => mockBloc.state).thenReturn(initial);

    whenListen(
      mockBloc,
      Stream<ProfileInfoState>.fromIterable([initial, loaded]),
      initialState: initial,
    );

    await tester.pumpWidget(
      makeTestApp(
        child: const ProfileInfoPage(),
        blocProviders: [BlocProvider<ProfileInfoBloc>.value(value: mockBloc)],
      ),
    );
    await tester.pump();

    expect(find.byType(ProfileInfoContent), findsOneWidget);
  });

  testWidgets(
    'Shows error UI and retry button when ProfileInfoError is emitted',
    (tester) async {
      const initial = ProfileInfoInitial();
      const error = ProfileInfoError('Some error occurred');

      when(() => mockBloc.state).thenReturn(initial);

      whenListen(
        mockBloc,
        Stream<ProfileInfoState>.fromIterable([initial, error]),
        initialState: initial,
      );

      await tester.pumpWidget(
        makeTestApp(
          child: const ProfileInfoPage(),
          blocProviders: [BlocProvider<ProfileInfoBloc>.value(value: mockBloc)],
        ),
      );
      await tester.pump();

      expect(find.text('Error: Something went wrong...'), findsOneWidget);

      final retryFinder = find.text('try again');
      expect(retryFinder, findsOneWidget);

      await tester.tap(retryFinder);
      await tester.pump();
      verify(() => mockBloc.add(const LoadUserProfile())).called(2);
    },
  );
}
