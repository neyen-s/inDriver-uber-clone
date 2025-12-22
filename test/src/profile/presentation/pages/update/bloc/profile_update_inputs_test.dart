import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/bloc/profile_update_inputs.dart';

void main() {
  group('Name Input', () {
    test('valid Name', () {
      const input = NameInput.dirty('Mateo');
      expect(input.error, isNull);
      expect(input.isInvalid, isFalse);
    });

    test('empty name is invalid', () {
      const input = NameInput.dirty();
      expect(input.error, isNotNull);
      expect(input.isInvalid, isTrue);
    });

    test('Name is too short', () {
      const input = NameInput.dirty('M');
      expect(input.error, isNotNull);
      expect(input.isInvalid, isTrue);
    });
  });
  group('Lastname Input', () {
    test('valid Lastname', () {
      const input = LastnameInput.dirty('Matus');
      expect(input.error, isNull);
      expect(input.isInvalid, isFalse);
    });

    test('empty Lastname is invalid', () {
      const input = LastnameInput.dirty();
      expect(input.error, isNotNull);
      expect(input.isInvalid, isTrue);
    });

    test('LastName is too short', () {
      const input = LastnameInput.dirty('M');
      expect(input.error, isNotNull);
      expect(input.isInvalid, isTrue);
    });
  });

  group('Phone input', () {
    test('valid Phone number', () {
      const input = PhoneInput.dirty('664410988');
      expect(input.error, isNull);
      expect(input.isInvalid, isFalse);
    });

    test('empty phone is invalid', () {
      const input = PhoneInput.dirty();
      expect(input.error, isNotNull);
      expect(input.isInvalid, isTrue);
    });

    test('invalid Phone number', () {
      const input = PhoneInput.dirty('@66441098s');
      expect(input.error, isNotNull);
      expect(input.isInvalid, isTrue);
    });
  });
  group('Email input', () {
    test('valid Email', () {
      const input = EmailInput.dirty('ds@gmail.com');
      expect(input.error, isNull);
      expect(input.isNotValid, isFalse);
    });

    test('empty email is invalid', () {
      const input = EmailInput.dirty();
      expect(input.error, isNotNull);
      expect(input.isNotValid, isTrue);
    });

    test('invalid Email', () {
      const input = EmailInput.dirty('@ds.com');
      expect(input.error, isNotNull);
      expect(input.isNotValid, isTrue);
    });
  });
  group('Password input', () {
    test('valid Password', () {
      const input = PasswordInput.dirty('123456');
      expect(input.error, isNull);
      expect(input.isNotValid, isFalse);
    });

    test('empty Password is invalid', () {
      const input = PasswordInput.dirty();
      expect(input.error, isNotNull);
      expect(input.isNotValid, isTrue);
    });

    test('invalid Password', () {
      const input = PasswordInput.dirty('12345');
      expect(input.error, isNotNull);
      expect(input.isNotValid, isTrue);
    });
  });
  group('Confirm Password input', () {
    test('valid Password', () {
      const input = ConfirmPasswordInput.dirty(
        password: '123456',
        value: '123456',
      );
      expect(input.error, isNull);
      expect(input.isNotValid, isFalse);
    });

    test('invalid confirm Password', () {
      const input = ConfirmPasswordInput.dirty(
        password: '123456',
        value: '1234567',
      );
      expect(input.error, isNotNull);
      expect(input.isNotValid, isTrue);
    });
  });
}
