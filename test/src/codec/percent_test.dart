import 'package:numeral/src/codec/compact.dart';
import 'package:numeral/src/codec/percent.dart';
import 'package:numeral/src/unit.dart';
import 'package:test/test.dart';

void main() {
  group('PercentCodec', () {
    test('formats ratios as percentages', () {
      final codec = PercentCodec(maxFractionDigits: 1);

      expect(codec.format(0.1234), '12.3%');
      expect(codec.format(1), '100%');
      expect(codec.format(double.infinity), '∞%');
      expect(codec.format(double.negativeInfinity), '-∞%');
      expect(codec.format(double.nan), 'NaN%');
    });

    test('does not emit negative zero after rounding', () {
      final codec = PercentCodec(maxFractionDigits: 0);

      expect(codec.format(-0.001), '0%');
      expect(codec.parse('0%'), 0);
    });

    test('parses percentages directly to double', () {
      final codec = PercentCodec();
      final comma = PercentCodec(decimalSeparator: ',');

      expect(codec.parse('12.5%'), 0.125);
      expect(codec.parse('-50%'), -0.5);
      expect(codec.parse('∞%'), double.infinity);
      expect(codec.parse('-∞%'), double.negativeInfinity);
      expect(codec.parse('NaN%').isNaN, isTrue);
      expect(codec.tryParse('12.5'), isNull);
      expect(comma.parse('12,5%'), 0.125);
      expect(comma.tryParse('12.5%'), isNull);
    });

    test('supports custom symbols, scale, and optional symbols', () {
      final basisPoints = PercentCodec(symbol: 'bp', scale: 10000);
      final optional = PercentCodec(requireSymbol: false);
      final spaced = PercentCodec(spaceBeforeSymbol: true);

      expect(basisPoints.format(0.0123), '123bp');
      expect(basisPoints.parse('123bp'), 0.0123);
      expect(optional.parse('12.5'), 0.125);
      expect(spaced.format(0.5), '50 %');
      expect(spaced.format(double.infinity), '∞ %');
      expect(spaced.parse('∞ %'), double.infinity);
    });

    test('can use a custom number style', () {
      final codec = PercentCodec(
        style: CompactCodec(
          unitSet: _chineseUnits,
          maxFractionDigits: 0,
        ),
      );

      expect(codec.format(10000), '100万%');
      expect(codec.parse('100万%'), 10000);
    });

    test('rejects invalid options', () {
      expect(() => PercentCodec(scale: 0), throwsA(isA<ArgumentError>()));
      expect(() => PercentCodec(scale: -100), throwsA(isA<ArgumentError>()));
      expect(
        () => PercentCodec(scale: double.infinity),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => PercentCodec(scale: double.nan),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => PercentCodec(maxFractionDigits: 21),
        throwsA(isA<ArgumentError>()),
      );
      expect(() => PercentCodec(symbol: ''), throwsA(isA<ArgumentError>()));
      expect(() => PercentCodec(symbol: ' '), throwsA(isA<ArgumentError>()));
    });
  });
}

const _chineseUnits = NumeralUnitSet([
  NumeralUnit(1, ''),
  NumeralUnit(10000, '万'),
]);
