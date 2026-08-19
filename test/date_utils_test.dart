import 'package:everyday_calculator/core/date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calendarDiff', () {
    test('plain difference', () {
      final diff = calendarDiff(DateTime(2000, 1, 15), DateTime(2003, 4, 20));
      expect(diff.years, 3);
      expect(diff.months, 3);
      expect(diff.days, 5);
    });

    test('month-end borrowing stays positive', () {
      final diff = calendarDiff(DateTime(2000, 1, 31), DateTime(2000, 3, 1));
      expect(diff.years, 0);
      expect(diff.months, 1);
      expect(diff.days, 1);
    });

    test('day before a birthday is not a full year', () {
      final diff = calendarDiff(DateTime(1990, 5, 20), DateTime(2020, 5, 19));
      expect(diff.years, 29);
      expect(diff.months, 11);
    });

    test('exact birthday', () {
      final diff = calendarDiff(DateTime(1990, 5, 20), DateTime(2020, 5, 20));
      expect(diff.years, 30);
      expect(diff.months, 0);
      expect(diff.days, 0);
    });

    test('order does not matter', () {
      final forward = calendarDiff(DateTime(2020, 1, 1), DateTime(2021, 6, 15));
      final backward = calendarDiff(DateTime(2021, 6, 15), DateTime(2020, 1, 1));
      expect(forward, backward);
    });
  });

  group('daysBetween', () {
    test('leap year February', () {
      expect(daysBetween(DateTime(2024, 2, 1), DateTime(2024, 3, 1)), 29);
      expect(daysBetween(DateTime(2023, 2, 1), DateTime(2023, 3, 1)), 28);
    });

    test('is signed', () {
      expect(daysBetween(DateTime(2024, 5, 10), DateTime(2024, 5, 1)), -9);
    });
  });

  group('weekdaysBetween', () {
    test('a full week has five weekdays', () {
      // 1 Jan 2024 is a Monday.
      expect(weekdaysBetween(DateTime(2024, 1, 1), DateTime(2024, 1, 8)), 5);
    });

    test('weekend only', () {
      // Saturday to Monday.
      expect(weekdaysBetween(DateTime(2024, 1, 6), DateTime(2024, 1, 8)), 0);
    });

    test('partial week', () {
      // Monday to Thursday = Mon, Tue, Wed.
      expect(weekdaysBetween(DateTime(2024, 1, 1), DateTime(2024, 1, 4)), 3);
    });

    test('a whole non-leap year', () {
      expect(weekdaysBetween(DateTime(2023, 1, 1), DateTime(2024, 1, 1)), 260);
    });
  });

  group('addMonths', () {
    test('clamps to the end of a short month', () {
      expect(addMonths(DateTime(2024, 1, 31), 1), DateTime(2024, 2, 29));
      expect(addMonths(DateTime(2023, 1, 31), 1), DateTime(2023, 2, 28));
    });

    test('crosses years in both directions', () {
      expect(addMonths(DateTime(2024, 11, 15), 3), DateTime(2025, 2, 15));
      expect(addMonths(DateTime(2024, 2, 15), -3), DateTime(2023, 11, 15));
    });
  });

  group('nextAnniversary', () {
    test('rolls to next year when the date has passed', () {
      final next = nextAnniversary(DateTime(1990, 3, 10), DateTime(2024, 6, 1));
      expect(next, DateTime(2025, 3, 10));
    });

    test('is strictly after the reference date', () {
      final next = nextAnniversary(DateTime(1990, 6, 1), DateTime(2024, 6, 1));
      expect(next, DateTime(2025, 6, 1));
    });
  });

  test('isLeapYear follows the century rule', () {
    expect(isLeapYear(2000), isTrue);
    expect(isLeapYear(1900), isFalse);
    expect(isLeapYear(2024), isTrue);
    expect(isLeapYear(2023), isFalse);
  });
}
