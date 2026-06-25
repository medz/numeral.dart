import 'package:numeral/src/_utils.dart';
import 'package:numeral/src/rounding.dart';
import 'package:test/test.dart';

void main() {
  group('_utils', () {
    test('fixedDecimal supports half-up and truncate rounding', () {
      expect(fixedDecimal(1.235, 2, Rounding.halfUp), '1.24');
      expect(fixedDecimal(1.239, 2, Rounding.truncate), '1.23');
      expect(fixedDecimal(-1.239, 2, Rounding.truncate), '-1.23');
      expect(fixedDecimal(1.9, 0, Rounding.truncate), '1');
      expect(fixedDecimal(-0.001, 2, Rounding.halfUp), '0.00');
      expect(fixedDecimal(-0.001, 0, Rounding.halfUp), '0');
    });

    test('normalizeFraction trims trailing zeros down to the minimum', () {
      expect(normalizeFraction('2300', 0, true), '23');
      expect(normalizeFraction('2300', 2, true), '23');
      expect(normalizeFraction('2000', 2, true), '20');
      expect(normalizeFraction('2300', 0, false), '2300');
    });

    test('formatSpecial handles non-finite values', () {
      expect(formatSpecial(double.nan), 'NaN');
      expect(formatSpecial(double.infinity), '∞');
      expect(formatSpecial(double.negativeInfinity), '-∞');
      expect(formatSpecial(1), isNull);
    });

    test('normalizeNum preserves non-integers and normalizes close integers',
        () {
      expect(normalizeNum(1.0000000005), 1);
      expect(normalizeNum(1.25), 1.25);
      expect(normalizeNum(double.infinity), double.infinity);
    });

    test('stripSuffix trims the suffix or validates it', () {
      expect(stripSuffix(' 1 KB ', 'KB', require: true), '1');
      expect(stripSuffix(' 1 ', 'KB', require: false), '1');
      expect(
        () => stripSuffix('1 MB', 'KB', require: true),
        throwsA(isA<FormatException>()),
      );
    });

    test('validation helpers reject invalid input', () {
      expect(() => checkFractionDigits(-1, 1), throwsA(isA<ArgumentError>()));
      expect(() => checkFractionDigits(0, -1), throwsA(isA<ArgumentError>()));
      expect(() => checkFractionDigits(0, 21), throwsA(isA<ArgumentError>()));
      expect(() => checkFractionDigits(2, 1), throwsA(isA<ArgumentError>()));
      expect(() => checkNotEmpty('', 'value'), throwsA(isA<ArgumentError>()));
    });
  });
}
