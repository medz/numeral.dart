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
    });

    test('parses grouped values directly to num', () {
      final codec = DecimalCodec();

      expect(codec.parse('1,234.5'), 1234.5);
      expect(codec.parse('-1,234'), -1234);
      expect(codec.tryParse('not a number'), isNull);
    });

    test('rejects invalid options', () {
      expect(
        () => DecimalCodec(minFractionDigits: 2, maxFractionDigits: 1),
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
    });
  });
}
