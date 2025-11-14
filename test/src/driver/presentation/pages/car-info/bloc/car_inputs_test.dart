import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/car-info/bloc/car_inputs.dart';

void main() {
  group('BrandInput', () {
    test('valid brand', () {
      const input = BrandInput.dirty('Mazda');
      expect(input.error, isNull);
      expect(input.isInvalid, isFalse);
    });

    test('empty brand is invalid', () {
      const input = BrandInput.dirty();
      expect(input.error, isNotNull);
      expect(input.isInvalid, isTrue);
    });

    test('too short brand is invalid', () {
      const input = BrandInput.dirty('A');
      expect(input.error, isNotNull);
      expect(input.isInvalid, isTrue);
    });
  });

  group('PlateInput', () {
    test('valid plate format', () {
      const input = PlateInput.dirty('0768 OWJ');
      expect(input.error, isNull);
      expect(input.isInvalid, isFalse);
    });

    test('empty plate is invalid', () {
      const input = PlateInput.dirty();
      expect(input.error, isNotNull);
      expect(input.isInvalid, isTrue);
    });

    test('invalid format plate', () {
      const input = PlateInput.dirty('@@@');
      expect(input.error, isNotNull);
      expect(input.isInvalid, isTrue);
    });
  });

  group('ColorInput', () {
    test('valid color', () {
      const input = ColorInput.dirty('Red');
      expect(input.error, isNull);
      expect(input.isInvalid, isFalse);
    });

    test('empty color is invalid', () {
      const input = ColorInput.dirty();
      expect(input.error, isNotNull);
      expect(input.isInvalid, isTrue);
    });
  });
}
