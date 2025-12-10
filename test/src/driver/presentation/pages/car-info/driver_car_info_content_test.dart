// test/driver/car_info/driver_car_info_content_test.dart

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_text_field.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/car-info/bloc/car_inputs.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/car-info/bloc/driver_car_info_bloc.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/car-info/driver_car_info_content.dart';
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
      // designSize: const Size(375, 812),
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

  testWidgets('smoke test: renders fields and header', (tester) async {
    // Arrange
    const initialState = DriverCarInfoState();

    // emits initial state
    when(() => mockBloc.state).thenReturn(initialState);
    whenListen(
      mockBloc,
      Stream<DriverCarInfoState>.fromIterable([initialState]),
      initialState: initialState,
    );

    // Act
    await tester.pumpWidget(
      createTestWidget(child: const DriverCarInfoContent()),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(
      find.byWidgetPredicate(
        (w) => w is DefaultTextField && w.hintText == 'Brand',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is DefaultTextField && w.hintText == 'Car Color',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is DefaultTextField && w.hintText == 'Plate',
      ),
      findsOneWidget,
    );

    // Header y action text deberían aparecer
    expect(find.text('EDIT PROFILE'), findsOneWidget);
    expect(find.text('UPDATE PROFILE'), findsOneWidget);
  });

  testWidgets('when bloc emits new values, controllers update', (tester) async {
    const state1 = DriverCarInfoState(); // valores vacíos
    final state2 = state1.copyWith(
      brand: const BrandInput.dirty('Toyota'),
      color: const ColorInput.dirty('Red'),
      plate: const PlateInput.dirty('ABC123'),
      isLoading: false,
    );

    //to manage the stream of states
    final controller = StreamController<DriverCarInfoState>();

    when(() => mockBloc.state).thenReturn(state1);
    whenListen(mockBloc, controller.stream, initialState: state1);

    await tester.pumpWidget(
      createTestWidget(child: const DriverCarInfoContent()),
    );
    await tester.pump();

    final brandFinder = find.byWidgetPredicate(
      (w) => w is DefaultTextField && w.hintText == 'Brand',
    );
    expect(brandFinder, findsOneWidget);
    final brandWidget = tester.widget<DefaultTextField>(brandFinder);
    expect(brandWidget.controller.text, ''); // inicialmente vacío

    controller.add(state2);
    await tester.pumpAndSettle();

    final updatedBrandWidget = tester.widget<DefaultTextField>(brandFinder);
    expect(updatedBrandWidget.controller.text, 'Toyota');

    await controller.close();
  });
  testWidgets('losing focus after editing dispatches BrandChanged', (
    tester,
  ) async {
    const initial = DriverCarInfoState();
    when(() => mockBloc.state).thenReturn(initial);
    whenListen(
      mockBloc,
      Stream<DriverCarInfoState>.fromIterable([initial]),
      initialState: initial,
    );

    await tester.pumpWidget(
      createTestWidget(child: const DriverCarInfoContent()),
    );
    await tester.pumpAndSettle();

    final brandFieldFinder = find.byWidgetPredicate(
      (w) => w is DefaultTextField && w.hintText == 'Brand',
    );
    final innerTextFormField = find.descendant(
      of: brandFieldFinder,
      matching: find.byType(TextFormField),
    );

    await tester.tap(innerTextFormField);
    await tester.pump();
    await tester.enterText(innerTextFormField, 'Fiat');
    await tester.testTextInput.receiveAction(TextInputAction.done);

    await tester.tap(find.byType(Scaffold));
    await tester.pumpAndSettle();

    final captured = verify(() => mockBloc.add(captureAny())).captured;

    final found = captured.any((e) => e is BrandChanged && e.brand == 'Fiat');
    expect(found, isTrue);
  });

  group('dialog test', () {
    testWidgets('confirm dialog -> on confirm dispatch SubmitCarChanges', (
      tester,
    ) async {
      const initial = DriverCarInfoState();
      when(() => mockBloc.state).thenReturn(initial);
      whenListen(
        mockBloc,
        Stream<DriverCarInfoState>.fromIterable([initial]),
        initialState: initial,
      );

      await tester.pumpWidget(
        createTestWidget(child: const DriverCarInfoContent()),
      );
      await tester.pumpAndSettle();

      final actionFinder = find.text('UPDATE PROFILE');
      expect(actionFinder, findsOneWidget);
      await tester.tap(actionFinder);
      await tester.pumpAndSettle();

      expect(find.text('Confirm changes'), findsOneWidget);
      expect(
        find.text('Are you sure you want to update your profile?'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(TextButton, 'Confirm'));
      await tester.pumpAndSettle();

      final captured = verify(() => mockBloc.add(captureAny())).captured;
      expect(captured.any((e) => e is SubmitCarChanges), isTrue);
    });

    testWidgets('confirm dialog -> on cancel no dispatch', (tester) async {
      const initial = DriverCarInfoState();
      when(() => mockBloc.state).thenReturn(initial);
      whenListen(
        mockBloc,
        Stream<DriverCarInfoState>.fromIterable([initial]),
        initialState: initial,
      );

      await tester.pumpWidget(
        createTestWidget(child: const DriverCarInfoContent()),
      );
      await tester.pumpAndSettle();

      final actionFinder = find.text('UPDATE PROFILE');
      expect(actionFinder, findsOneWidget);
      await tester.tap(actionFinder);
      await tester.pumpAndSettle();

      expect(find.text('Confirm changes'), findsOneWidget);
      expect(
        find.text('Are you sure you want to update your profile?'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      verifyNever(() => mockBloc.add(SubmitCarChanges()));
    });
  });
}
