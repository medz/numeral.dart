import 'package:numeral/numeral.dart' as numeral;
import 'package:test/test.dart';

void main() {
  group('decimal', () {
    test('formats grouped decimal values', () {
      final formatter = numeral.decimal(
        minFractionDigits: 2,
        maxFractionDigits: 2,
      );

      expect(formatter.format(1234567.8), '1,234,567.80');
      expect(formatter.format(-1234.567), '-1,234.57');
      expect(formatter.format(double.infinity), '∞');
      expect(formatter.format(double.negativeInfinity), '-∞');
      expect(formatter.format(double.nan), 'NaN');
    });

    test('can truncate instead of rounding', () {
      final formatter = numeral.decimal(
        maxFractionDigits: 2,
        rounding: numeral.Rounding.truncate,
      );

      expect(formatter.format(1234.569), '1,234.56');
      expect(formatter.format(-1234.569), '-1,234.56');
    });

    test('parses grouped values directly to num', () {
      final formatter = numeral.decimal();

      expect(formatter.parse('1,234.5'), 1234.5);
      expect(formatter.parse('-1,234'), -1234);
      expect(formatter.tryParse('not a number'), isNull);
    });
  });

  group('compact', () {
    test('formats western compact numbers', () {
      final formatter = numeral.compact(maxFractionDigits: 1);

      expect(formatter.format(1234), '1.2K');
      expect(formatter.format(1234567), '1.2M');
      expect(formatter.format(-1234567), '-1.2M');
    });

    test('moves rounded overflow to the next unit', () {
      final formatter = numeral.compact(maxFractionDigits: 0);

      expect(formatter.format(999999), '1M');
      expect(formatter.format(999999999), '1B');
    });

    test('supports Chinese compact units', () {
      final formatter = numeral.compact(
        unitSet: numeral.CompactUnitSet.chinese,
        maxFractionDigits: 2,
      );

      expect(formatter.format(1234567), '123.46万');
      expect(formatter.format(120000000), '1.2亿');
    });

    test('parses compact suffixes directly to num', () {
      final formatter = numeral.compact();
      final zh = numeral.compact(unitSet: numeral.CompactUnitSet.chinese);

      expect(formatter.parse('1.2K'), 1200);
      expect(formatter.parse('3 million'), 3000000);
      expect(formatter.parse('-1.5B'), -1500000000);
      expect(zh.parse('3.5万'), 35000);
      expect(formatter.tryParse('abc'), isNull);
    });
  });

  group('percent', () {
    test('formats ratios as percentages', () {
      final formatter = numeral.percent(maxFractionDigits: 1);

      expect(formatter.format(0.1234), '12.3%');
      expect(formatter.format(1), '100%');
    });

    test('parses percentages directly to double', () {
      final formatter = numeral.percent();

      expect(formatter.parse('12.5%'), 0.125);
      expect(formatter.parse('-50%'), -0.5);
      expect(formatter.tryParse('12.5'), isNull);
    });
  });

  group('bytes', () {
    test('formats decimal byte sizes', () {
      final formatter = numeral.bytes(maxFractionDigits: 1);

      expect(formatter.format(999), '999 B');
      expect(formatter.format(1000), '1 KB');
      expect(formatter.format(1500), '1.5 KB');
      expect(formatter.format(2500000), '2.5 MB');
    });

    test('formats binary byte sizes', () {
      final formatter = numeral.bytes(binary: true, maxFractionDigits: 1);

      expect(formatter.format(1024), '1 KiB');
      expect(formatter.format(1536), '1.5 KiB');
      expect(formatter.format(1048576), '1 MiB');
    });

    test('parses byte sizes directly to int', () {
      final decimal = numeral.bytes();
      final binary = numeral.bytes(binary: true);

      expect(decimal.parse('1 KB'), 1000);
      expect(decimal.parse('1.5 MB'), 1500000);
      expect(binary.parse('1.5 KiB'), 1536);
      expect(binary.tryParse('0.1 B'), isNull);
    });
  });

  group('currency', () {
    test('formats and parses display currency values', () {
      final usd = numeral.currency(r'$');
      final cny = numeral.currency(
        '元',
        symbolOnRight: true,
        spaceBetweenSymbolAndNumber: true,
        maxFractionDigits: 0,
        minFractionDigits: 0,
      );

      expect(usd.format(1234.5), r'$1,234.50');
      expect(usd.format(-1234.5), r'-$1,234.50');
      expect(usd.parse(r'$1,234.50'), 1234.5);
      expect(usd.parse(r'-$1,234.50'), -1234.5);
      expect(cny.format(99), '99 元');
      expect(cny.parse('99 元'), 99);
    });
  });
}
