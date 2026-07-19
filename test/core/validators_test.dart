import 'package:flutter_test/flutter_test.dart';
import 'package:urbanthread/core/utils/validators.dart';

/// These mirror the backend's express-validator rules. Where they drift, a
/// user either gets blocked on a field the server would have accepted, or
/// sails through to a confusing 422 — so the boundaries are worth pinning.
void main() {
  group('password', () {
    test('accepts a password meeting every backend rule', () {
      // Backend: ≥8 chars, one upper, one lower, one digit.
      expect(Validators.password('Str0ngPass'), isNull);
    });

    test('names the specific rule that failed', () {
      // A single "invalid password" leaves the user guessing which of the
      // four conditions they missed.
      expect(Validators.password('Sh0rt'), contains('8 characters'));
      expect(Validators.password('lowercase1'), contains('uppercase'));
      expect(Validators.password('UPPERCASE1'), contains('lowercase'));
      expect(Validators.password('NoDigitsHere'), contains('number'));
      expect(Validators.password(''), contains('required'));
    });

    test('login only checks presence', () {
      // Accounts predating the current policy must still be able to sign in;
      // applying the full rule here would lock them out of their own account
      // before the request is even sent.
      expect(Validators.loginPassword('old'), isNull);
      expect(Validators.loginPassword(''), isNotNull);
    });
  });

  group('email', () {
    test('accepts ordinary addresses', () {
      for (final address in [
        'aarav@example.com',
        'first.last@sub.domain.co.uk',
        'user+tag@example.io',
      ]) {
        expect(Validators.email(address), isNull, reason: address);
      }
    });

    test('rejects malformed addresses', () {
      for (final address in ['plainstring', 'no@tld', '@example.com', 'a b@c.com']) {
        expect(Validators.email(address), isNotNull, reason: address);
      }
    });
  });

  group('phone', () {
    test('matches the backend pattern', () {
      // Backend: /^[+]?[\d\s().-]{7,20}$/
      expect(Validators.phone('+9779812345678'), isNull);
      expect(Validators.phone('01-4444444'), isNull);
      expect(Validators.phone('123'), isNotNull);
    });

    test('is optional unless required', () {
      expect(Validators.phone(''), isNull);
      expect(Validators.phone('', isRequired: true), isNotNull);
    });
  });

  group('name', () {
    test('enforces the backend 2..80 bound', () {
      expect(Validators.name('Aarav Sharma'), isNull);
      expect(Validators.name('A'), isNotNull);
      expect(Validators.name('x' * 81), isNotNull);
      expect(Validators.name('x' * 80), isNull);
    });
  });

  group('reviewComment', () {
    test('enforces the backend 10..2000 bound', () {
      expect(Validators.reviewComment('Too short'), isNotNull);
      expect(Validators.reviewComment('Just about long enough'), isNull);
      expect(Validators.reviewComment('x' * 2001), isNotNull);
    });
  });

  group('confirmPassword', () {
    test('requires an exact match', () {
      expect(Validators.confirmPassword('Str0ngPass', 'Str0ngPass'), isNull);
      expect(Validators.confirmPassword('Str0ngPas', 'Str0ngPass'), isNotNull);
      expect(Validators.confirmPassword('', 'Str0ngPass'), isNotNull);
    });
  });

  group('all', () {
    test('reports the first failing rule', () {
      final validate = Validators.all([
        (value) => Validators.required(value, field: 'Code'),
        Validators.couponCode,
      ]);

      expect(validate(''), contains('required'));
      expect(validate('ab'), isNotNull);
      expect(validate('WELCOME10'), isNull);
    });
  });
}
