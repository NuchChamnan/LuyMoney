import 'package:flutter_test/flutter_test.dart';
import 'package:luy_money/app/shared/utils/app_utils.dart';

void main() {
  group('AppValidators', () {
    // ── Email ─────────────────────────────────────────────────────────────────
    group('email', () {
      test('returns null for valid email', () {
        expect(AppValidators.email('test@example.com'), isNull);
        expect(AppValidators.email('user.name+tag@domain.co'), isNull);
      });

      test('returns error for empty email', () {
        expect(AppValidators.email(''), isNotNull);
        expect(AppValidators.email(null), isNotNull);
      });

      test('returns error for invalid email format', () {
        expect(AppValidators.email('notanemail'), isNotNull);
        expect(AppValidators.email('missing@domain'), isNotNull);
        expect(AppValidators.email('@nodomain.com'), isNotNull);
      });
    });

    // ── Password ──────────────────────────────────────────────────────────────
    group('password', () {
      test('returns null for valid password (6+ chars)', () {
        expect(AppValidators.password('secret'), isNull);
        expect(AppValidators.password('MyP@ssw0rd'), isNull);
      });

      test('returns error for short password', () {
        expect(AppValidators.password('abc'), isNotNull);
        expect(AppValidators.password('12345'), isNotNull);
      });

      test('returns error for empty password', () {
        expect(AppValidators.password(''), isNotNull);
        expect(AppValidators.password(null), isNotNull);
      });
    });

    // ── Confirm password ──────────────────────────────────────────────────────
    group('confirmPassword', () {
      test('returns null when passwords match', () {
        expect(AppValidators.confirmPassword('secret', 'secret'), isNull);
      });

      test('returns error when passwords differ', () {
        expect(AppValidators.confirmPassword('secret', 'other'), isNotNull);
      });

      test('returns error for empty confirm', () {
        expect(AppValidators.confirmPassword('', 'secret'), isNotNull);
        expect(AppValidators.confirmPassword(null, 'secret'), isNotNull);
      });
    });

    // ── Name ──────────────────────────────────────────────────────────────────
    group('name', () {
      test('returns null for valid name', () {
        expect(AppValidators.name('John'), isNull);
        expect(AppValidators.name('Sok Dara'), isNull);
      });

      test('returns error for empty name', () {
        expect(AppValidators.name(''), isNotNull);
        expect(AppValidators.name(null), isNotNull);
      });

      test('returns error for single-char name', () {
        expect(AppValidators.name('A'), isNotNull);
      });
    });
  });

  // ── DateHelper ────────────────────────────────────────────────────────────
  group('DateHelper', () {
    test('formatDate produces readable date', () {
      final date = DateTime(2025, 3, 15);
      expect(DateHelper.formatDate(date), equals('Mar 15, 2025'));
    });

    test('timeAgo returns "just now" for recent time', () {
      final recent = DateTime.now().subtract(const Duration(seconds: 30));
      expect(DateHelper.timeAgo(recent), equals('just now'));
    });

    test('timeAgo returns hours ago correctly', () {
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
      expect(DateHelper.timeAgo(twoHoursAgo), equals('2h ago'));
    });

    test('timeAgo returns days ago correctly', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      expect(DateHelper.timeAgo(threeDaysAgo), equals('3d ago'));
    });
  });

  // ── CurrencyHelper ────────────────────────────────────────────────────────
  group('CurrencyHelper', () {
    test('formatUsd formats correctly', () {
      expect(CurrencyHelper.formatUsd(5.0), equals('\$5.00'));
      expect(CurrencyHelper.formatUsd(35.0), equals('\$35.00'));
    });
  });

  // ── StringExt ─────────────────────────────────────────────────────────────
  group('StringExt', () {
    test('truncate shortens long strings', () {
      expect('Hello World'.truncate(5), equals('Hello...'));
      expect('Hi'.truncate(5), equals('Hi'));
    });

    test('isValidEmail correctly validates', () {
      expect('test@example.com'.isValidEmail, isTrue);
      expect('invalid'.isValidEmail, isFalse);
    });
  });
}
