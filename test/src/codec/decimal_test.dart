import 'package:numeral/src/codec/decimal.dart';
import 'package:numeral/src/rounding.dart';
import 'package:test/test.dart';

void main() {
  group('DecimalCodec', () {
    test('formats grouped decimal values and special values', () {
      final codec = DecimalCodec(
        minFractionDigits: 2,
        maxFractionDigits: 2,
      );

      expect(codec.format(1234567.8), '1,234,567.80');
      expect(codec.format(-1234.567), '-1,234.57');
      expect(codec.format(double.infinity), '∞');
      expect(codec.format(double.negativeInfinity), '-∞');
      expect(codec.format(double.nan), 'NaN');
    });

    test('does not emit negative zero after rounding', () {
      expect(DecimalCodec(maxFractionDigits: 0).format(-0.1), '0');
      expect(DecimalCodec(maxFractionDigits: 2).format(-0.001), '0');
      expect(
        DecimalCodec(minFractionDigits: 2, maxFractionDigits: 2).format(-0.001),
        '0.00',
      );
    });

    test('can truncate instead of rounding', () {
      final codec = DecimalCodec(
        maxFractionDigits: 2,
        rounding: Rounding.truncate,
      );

      expect(codec.format(1234.569), '1,234.56');
      expect(codec.format(-1234.569), '-1,234.56');
    });

    test('supports custom separators', () {
      final codec = DecimalCodec(
        groupSeparator: '.',
        decimalSeparator: ',',
        minFractionDigits: 1,
        maxFractionDigits: 1,
      );

      expect(codec.format(1234567.8), '1.234.567,8');
      expect(codec.parse('1.234.567,8'), 1234567.8);
      expect(codec.tryParse('12.34,5'), isNull);
      expect(codec.tryParse('1234,5'), 1234.5);
    });

    test('supports non-grammar separator punctuation', () {
      final codec = DecimalCodec(
        groupSeparator: ' ',
        decimalSeparator: ',',
        maxFractionDigits: 1,
      );

      expect(codec.format(1234567.8), '1 234 567,8');
      expect(codec.parse('1 234 567,8'), 1234567.8);
    });

    test('parses grouped values directly to num', () {
      final codec = DecimalCodec();

      expect(codec.parse('1,234.5'), 1234.5);
      expect(codec.parse('1,234,567.5'), 1234567.5);
      expect(codec.parse('1234.5'), 1234.5);
      expect(codec.parse('1,234e2'), 123400);
      expect(codec.parse('-1,234'), -1234);
      expect(codec.tryParse('not a number'), isNull);
    });

    test('parses special values without exponent suffixes', () {
      final codec = DecimalCodec();

      expect(codec.parse('∞'), double.infinity);
      expect(codec.parse('+∞'), double.infinity);
      expect(codec.parse('-∞'), double.negativeInfinity);
      expect(codec.parse('Infinity'), double.infinity);
      expect(codec.parse('-Infinity'), double.negativeInfinity);
      expect(codec.parse('NaN').isNaN, isTrue);
      expect(codec.tryParse('NaNe2'), isNull);
      expect(codec.tryParse('Infinitye2'), isNull);
      expect(codec.tryParse('∞e2'), isNull);
    });

    test('rejects malformed grouped values', () {
      final codec = DecimalCodec();

      expect(codec.tryParse('12,34'), isNull);
      expect(codec.tryParse('1,,234'), isNull);
      expect(codec.tryParse(',123'), isNull);
      expect(codec.tryParse('123,'), isNull);
      expect(codec.tryParse('1,2345'), isNull);
      expect(codec.tryParse('1,234.5,6'), isNull);
      expect(codec.tryParse('1e1,000'), isNull);
    });

    test('rejects invalid options', () {
      expect(
        () => DecimalCodec(minFractionDigits: 2, maxFractionDigits: 1),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => DecimalCodec(maxFractionDigits: 21),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => DecimalCodec(decimalSeparator: ''),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => DecimalCodec(groupSeparator: ',', decimalSeparator: ','),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => DecimalCodec(groupSeparator: '..', decimalSeparator: '.'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => DecimalCodec(groupSeparator: '.', decimalSeparator: '..'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => DecimalCodec(decimalSeparator: 'e'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => DecimalCodec(decimalSeparator: '1'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => DecimalCodec(decimalSeparator: '-'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => DecimalCodec(groupSeparator: 'e'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => DecimalCodec(groupSeparator: '1'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => DecimalCodec(groupSeparator: '-'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
