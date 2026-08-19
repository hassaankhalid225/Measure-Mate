import 'package:everyday_calculator/core/formatting.dart';
import 'package:everyday_calculator/core/settings.dart';
import 'package:everyday_calculator/data/tools.dart';
import 'package:everyday_calculator/data/unit_categories.dart';
import 'package:flutter_test/flutter_test.dart';

double convert(String categoryId, String fromId, String toId, double value) {
  final category = categoryById(categoryId)!;
  return category.convert(
    value,
    category.unitById(fromId),
    category.unitById(toId),
  );
}

void main() {
  group('length', () {
    test('metre to foot', () {
      expect(convert('length', 'm', 'ft', 1), closeTo(3.280839895, 1e-9));
    });

    test('mile to kilometre', () {
      expect(convert('length', 'mi', 'km', 1), closeTo(1.609344, 1e-12));
    });

    test('round trip keeps the value', () {
      final out = convert('length', 'in', 'nmi', 12345.678);
      expect(convert('length', 'nmi', 'in', out), closeTo(12345.678, 1e-6));
    });
  });

  group('temperature', () {
    test('boiling point', () {
      expect(convert('temperature', 'c', 'f', 100), closeTo(212, 1e-9));
    });

    test('absolute zero', () {
      expect(convert('temperature', 'k', 'c', 0), closeTo(-273.15, 1e-9));
    });

    test('-40 is the same in both scales', () {
      expect(convert('temperature', 'c', 'f', -40), closeTo(-40, 1e-9));
    });

    test('rankine matches fahrenheit offset', () {
      expect(convert('temperature', 'f', 'r', 0), closeTo(459.67, 1e-9));
    });
  });

  group('data', () {
    test('gibibyte is 1024^3 bytes', () {
      expect(convert('data', 'gib', 'byte', 1), 1073741824);
    });

    test('gigabyte is smaller than gibibyte', () {
      expect(convert('data', 'gb', 'gib', 1), closeTo(0.9313225746, 1e-9));
    });

    test('byte to bit', () {
      expect(convert('data', 'byte', 'bit', 1), 8);
    });
  });

  group('fuel economy', () {
    test('km/L to L/100km is inverse', () {
      expect(convert('fuel_economy', 'kmpl', 'l100km', 20), closeTo(5, 1e-9));
      expect(convert('fuel_economy', 'l100km', 'kmpl', 5), closeTo(20, 1e-9));
    });

    test('km/L to US mpg', () {
      expect(
        convert('fuel_economy', 'kmpl', 'mpg_us', 10),
        closeTo(23.5214583, 1e-6),
      );
    });
  });

  group('other categories', () {
    test('bar to psi', () {
      expect(convert('pressure', 'bar', 'psi', 1), closeTo(14.5037738, 1e-6));
    });

    test('kilowatt to metric horsepower', () {
      expect(convert('power', 'kw', 'ps', 1), closeTo(1.35962162, 1e-6));
    });

    test('kilocalorie to kilojoule', () {
      expect(convert('energy', 'kcal', 'kj', 1), closeTo(4.184, 1e-9));
    });

    test('acre to square metre', () {
      expect(convert('area', 'acre', 'sqm', 1), closeTo(4046.8564224, 1e-6));
    });

    test('kilogram to pound', () {
      expect(convert('weight', 'kg', 'lb', 1), closeTo(2.20462262, 1e-6));
    });

    test('hour to minute', () {
      expect(convert('time', 'h', 'min', 1), 60);
    });

    test('turn to degree', () {
      expect(convert('angle', 'turn', 'deg', 1), 360);
    });
  });

  group('data integrity', () {
    test('every category has unique unit ids and valid defaults', () {
      for (final category in kUnitCategories) {
        final ids = category.units.map((unit) => unit.id).toList();
        expect(
          ids.toSet().length,
          ids.length,
          reason: 'duplicate unit id in ${category.id}',
        );
        expect(
          ids,
          contains(category.defaultFromId),
          reason: 'bad defaultFromId in ${category.id}',
        );
        expect(
          ids,
          contains(category.defaultToId),
          reason: 'bad defaultToId in ${category.id}',
        );
        expect(category.units.length, greaterThan(1));
      }
    });

    test('every default home tool id resolves to a real tool', () {
      for (final id in kDefaultHomeTools) {
        expect(toolById(id), isNotNull, reason: 'unknown default tool: $id');
      }
      expect(kDefaultHomeTools.toSet().length, kDefaultHomeTools.length);
    });

    test('tool ids are unique', () {
      final ids = kAllTools.map((tool) => tool.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('converting a unit to itself is a no-op', () {
      for (final category in kUnitCategories) {
        for (final unit in category.units) {
          expect(
            category.convert(7.5, unit, unit),
            closeTo(7.5, 1e-6),
            reason: '${category.id}/${unit.id}',
          );
        }
      }
    });
  });

  group('formatting', () {
    test('trims trailing zeros', () {
      expect(formatNumber(2.5000000), '2.5');
      expect(formatNumber(3), '3');
    });

    test('groups thousands', () {
      expect(formatNumberGrouped(1234567.5), '1,234,567.5');
      expect(formatMoney(1234.5), '1,234.50');
    });

    test('handles zero and infinity', () {
      expect(formatNumber(0), '0');
      expect(formatNumber(double.infinity), '∞');
    });

    test('parses grouped input', () {
      expect(parseNumber('1,250.75'), 1250.75);
      expect(parseNumber(''), isNull);
      expect(parseNumber('-'), isNull);
    });
  });
}
