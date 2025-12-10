import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/car-info/bloc/driver_car_info_bloc.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/car-info/driver_car_info_page.dart';
import 'package:mocktail/mocktail.dart';

class FakeDriverCarInfoEvent extends Fake implements DriverCarInfoEvent {}

class FakeDriverCarInfoState extends Fake implements DriverCarInfoState {}

class MockDriverCarInfoBloc
    extends MockBloc<DriverCarInfoEvent, DriverCarInfoState>
    implements DriverCarInfoBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDriverCarInfoEvent());
    registerFallbackValue(FakeDriverCarInfoState());
  });

  late MockDriverCarInfoBloc mockBloc;

  Widget createTestWidget({required Widget child}) {
    return ScreenUtilInit(
      builder: (context, widget) {
        return MaterialApp(
          home: Scaffold(
            body: BlocProvider<DriverCarInfoBloc>.value(
              value: mockBloc,
              child: child,
            ),
          ),
        );
      },
    );
  }

  setUp(() {
    mockBloc = MockDriverCarInfoBloc();
  });

  testWidgets('shows loader dialog when isLoading becomes true', (
    tester,
  ) async {
    const initial = DriverCarInfoState();
    final loading = initial.copyWith(isLoading: true);

    //actual state
    when(() => mockBloc.state).thenReturn(initial);

    //emits loading state
    whenListen(
      mockBloc,
      Stream<DriverCarInfoState>.fromIterable([initial, loading]),
      initialState: initial,
    );

    await tester.pumpWidget(createTestWidget(child: const DriverCarInfoPage()));

    await tester.pump();

    expect(find.text('Updating driver car info...'), findsOneWidget);
  });

  group('snackbar test', () {
    testWidgets('shows success snackbar when carInfoUpdated becomes true', (
      tester,
    ) async {
      const initial = DriverCarInfoState();
      final success = initial.copyWith(carInfoUpdated: true);

      when(() => mockBloc.state).thenReturn(initial);

      whenListen(
        mockBloc,
        Stream<DriverCarInfoState>.fromIterable([initial, success]),
        initialState: initial,
      );

      await tester.pumpWidget(
        createTestWidget(child: const DriverCarInfoPage()),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('Car information updated successfully!'),
        findsOneWidget,
      );
    });

    testWidgets('shows error snackbar when errorMessage is set', (
      tester,
    ) async {
      const initial = DriverCarInfoState();
      final errorState = initial.copyWith(errorMessage: 'Boom.');

      when(() => mockBloc.state).thenReturn(initial);
      whenListen(
        mockBloc,
        Stream<DriverCarInfoState>.fromIterable([initial, errorState]),
        initialState: initial,
      );

      await tester.pumpWidget(
        createTestWidget(child: const DriverCarInfoPage()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Boom.'), findsOneWidget);
    });
  });
}
