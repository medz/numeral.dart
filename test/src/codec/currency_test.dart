import 'package:numeral/src/codec/compact.dart';
import 'package:numeral/src/codec/currency.dart';
import 'package:numeral/src/unit.dart';
import 'package:test/test.dart';

void main() {
  group('CurrencyCodec', () {
    test('formats and parses display currency values', () {
      final usd = CurrencyCodec(r'$');
      final cny = CurrencyCodec(
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

    test('formats and parses compact currency amounts', () {
      final cnySymbol = CurrencyCodec(
        '¥',
        style: CompactCodec(
          unitSet: _chineseUnits,
          maxFractionDigits: 0,
        ),
      );
      final cnyUnit = CurrencyCodec(
        '元',
        symbolOnRight: true,
        style: CompactCodec(
          unitSet: _chineseUnits,
          maxFractionDigits: 0,
        ),
      );

      expect(cnySymbol.format(1000000), '¥100万');
      expect(cnySymbol.parse('¥100万'), 1000000);
      expect(cnyUnit.format(1000000), '100万元');
      expect(cnyUnit.parse('100万元'), 1000000);
    });

    test('rejects malformed grouped currency amounts', () {
      final usd = CurrencyCodec(r'$');

      expect(usd.tryParse(r'$12,34.00'), isNull);
      expect(usd.tryParse(r'$1,,234.00'), isNull);
      expect(usd.tryParse(r'$1,234.00'), 1234);
    });

    test('formats special values with the currency symbol', () {
      final usd = CurrencyCodec(r'$');

      expect(usd.format(double.infinity), r'$∞');
      expect(usd.format(double.negativeInfinity), r'$-∞');
    });

    test('rejects invalid symbols and missing parse symbols', () {
      final usd = CurrencyCodec(r'$');

      expect(() => CurrencyCodec(''), throwsA(isA<ArgumentError>()));
      expect(() => usd.parse('1.00'), throwsA(isA<FormatException>()));
    });
  });
}

const _chineseUnits = NumeralUnitSet([
  NumeralUnit(1, ''),
  NumeralUnit(10000, '万'),
]);
