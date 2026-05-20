import 'package:flutter_test/flutter_test.dart';
import 'package:luy_money/app/data/models/subscription_model.dart';

void main() {
  group('SubscriptionModel', () {
    SubscriptionModel makeSubscription({
      required DateTime expiryDate,
      bool isActive = true,
    }) {
      return SubscriptionModel(
        id: 'test_id',
        userId: 'user_123',
        planId: 'monthly',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        expiryDate: expiryDate,
        isActive: isActive,
        paymentMethod: 'stripe',
        transactionId: 'txn_123',
        amountPaid: 5.0,
      );
    }

    // ── isExpired ─────────────────────────────────────────────────────────────
    test('isExpired returns true when expiryDate is in the past', () {
      final sub = makeSubscription(
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(sub.isExpired, isTrue);
    });

    test('isExpired returns false when expiryDate is in the future', () {
      final sub = makeSubscription(
        expiryDate: DateTime.now().add(const Duration(days: 10)),
      );
      expect(sub.isExpired, isFalse);
    });

    test('isExpired returns false when expiryDate is today (same day)', () {
      final sub = makeSubscription(
        expiryDate: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(sub.isExpired, isFalse);
    });

    // ── daysRemaining ─────────────────────────────────────────────────────────
    test('daysRemaining is positive for future expiry', () {
      final sub = makeSubscription(
        expiryDate: DateTime.now().add(const Duration(days: 15)),
      );
      expect(sub.daysRemaining, greaterThan(0));
      expect(sub.daysRemaining, lessThanOrEqualTo(15));
    });

    test('daysRemaining is negative for past expiry', () {
      final sub = makeSubscription(
        expiryDate: DateTime.now().subtract(const Duration(days: 5)),
      );
      expect(sub.daysRemaining, isNegative);
    });

    test('daysRemaining is 0 for expiry in less than 24h', () {
      final sub = makeSubscription(
        expiryDate: DateTime.now().add(const Duration(hours: 12)),
      );
      expect(sub.daysRemaining, equals(0));
    });

    // ── isExpiringSoon ────────────────────────────────────────────────────────
    test('isExpiringSoon is true within 7 days', () {
      final sub = makeSubscription(
        expiryDate: DateTime.now().add(const Duration(days: 5)),
      );
      expect(sub.isExpiringSoon, isTrue);
    });

    test('isExpiringSoon is true at exactly 7 days', () {
      final sub = makeSubscription(
        expiryDate: DateTime.now().add(const Duration(days: 7)),
      );
      expect(sub.isExpiringSoon, isTrue);
    });

    test('isExpiringSoon is false when more than 7 days remain', () {
      final sub = makeSubscription(
        expiryDate: DateTime.now().add(const Duration(days: 30)),
      );
      expect(sub.isExpiringSoon, isFalse);
    });

    test('isExpiringSoon is false when already expired', () {
      final sub = makeSubscription(
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(sub.isExpiringSoon, isFalse);
    });

    // ── progressPercent ───────────────────────────────────────────────────────
    test('progressPercent is between 0 and 1', () {
      final sub = makeSubscription(
        expiryDate: DateTime.now().add(const Duration(days: 15)),
      );
      expect(sub.progressPercent, greaterThanOrEqualTo(0.0));
      expect(sub.progressPercent, lessThanOrEqualTo(1.0));
    });

    test('progressPercent is 1.0 when expired', () {
      final sub = makeSubscription(
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(sub.progressPercent, equals(1.0));
    });

    // ── Plans ─────────────────────────────────────────────────────────────────
    group('SubscriptionPlanInfo', () {
      test('monthly plan has correct price and duration', () {
        final plan = SubscriptionPlanInfo.plans
            .firstWhere((p) => p.id == 'monthly');
        expect(plan.price, equals(5.0));
        expect(plan.durationDays, equals(30));
      });

      test('annual plan is Best Value', () {
        final plan = SubscriptionPlanInfo.plans
            .firstWhere((p) => p.id == 'annual');
        expect(plan.badge, equals('best_value'));
        expect(plan.price, equals(35.0));
        expect(plan.durationDays, equals(365));
      });

      test('biannual plan is Popular', () {
        final plan = SubscriptionPlanInfo.plans
            .firstWhere((p) => p.id == 'biannual');
        expect(plan.badge, equals('popular'));
      });

      test('there are exactly 4 plans', () {
        expect(SubscriptionPlanInfo.plans.length, equals(4));
      });
    });
  });
}
