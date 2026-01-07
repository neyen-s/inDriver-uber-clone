import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_icon_back.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/bloc/profile_update_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/profile_update_content.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/action_profile.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/card_user_info.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/header_profile.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/test_app.dart';

class FakeUpdateProfileInfoEvent extends Fake implements ProfileUpdateEvent {}

class FakeUpdateProfileInfoState extends Fake implements ProfileUpdateState {}

class MockUpdateProfileInfoBloc
    extends MockBloc<ProfileUpdateEvent, ProfileUpdateState>
    implements ProfileUpdateBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUpdateProfileInfoEvent());
    registerFallbackValue(FakeUpdateProfileInfoState());
  });
  late MockUpdateProfileInfoBloc mockBloc;
  setUp(() {
    mockBloc = MockUpdateProfileInfoBloc();
  });

  testWidgets('renders ProfileUpdateContent with required widgets', (
    tester,
  ) async {
    final bloc = MockUpdateProfileInfoBloc();

    when(() => bloc.state).thenReturn(const ProfileUpdateState());

    await tester.pumpWidget(
      makeTestApp(
        child: const ProfileUpdateContent(user: null),
        blocProviders: [BlocProvider<ProfileUpdateBloc>.value(value: bloc)],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HeaderProfile), findsOneWidget);
    expect(find.byType(ProfileInfoCard), findsOneWidget);
    expect(find.byType(ActionProfile), findsOneWidget);
    expect(find.byType(DefaultIconBack), findsOneWidget);
    expect(find.text('UPDATE PROFILE'), findsOneWidget);
  });

  testWidgets('passes user data to ProfileInfoCard', (tester) async {
    final user = const UserEntity.empty().copyWith(
      name: 'John',
      lastname: 'Doe',
      phone: '+123456789',
    );

    const initialState = ProfileUpdateState();

    when(() => mockBloc.state).thenReturn(initialState);

    await tester.pumpWidget(
      makeTestApp(
        child: ProfileUpdateContent(user: user),
        blocProviders: [BlocProvider<ProfileUpdateBloc>.value(value: mockBloc)],
      ),
    );

    final card = tester.widget<ProfileInfoCard>(find.byType(ProfileInfoCard));

    expect(card.user?.name, 'John');
    expect(card.user?.lastname, 'Doe');
    expect(card.user?.phone, '+123456789');
  });

  testWidgets('shows confirm dialog and submits when confirmed', (
    tester,
  ) async {
    final bloc = MockUpdateProfileInfoBloc();

    when(() => bloc.state).thenReturn(const ProfileUpdateState());

    await tester.pumpWidget(
      makeTestApp(
        child: const ProfileUpdateContent(user: null),
        blocProviders: [BlocProvider<ProfileUpdateBloc>.value(value: bloc)],
      ),
    );

    await tester.pumpAndSettle();

    // Tap botón
    await tester.tap(find.text('UPDATE PROFILE'));
    await tester.pumpAndSettle();

    // Dialog visible
    expect(find.text('Confirm changes'), findsOneWidget);
    expect(
      find.text('Are you sure you want to update your profile?'),
      findsOneWidget,
    );

    // Confirmar
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    // Evento enviado al bloc
    verify(() => bloc.add(const SubmitProfileChanges())).called(1);
  });
}
