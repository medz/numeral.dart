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
      expect(codec.format(double.infinity), '∞');
    });

    test('parses percentages directly to double', () {
      final codec = PercentCodec();

      expect(codec.parse('12.5%'), 0.125);
      expect(codec.parse('-50%'), -0.5);
      expect(codec.tryParse('12.5'), isNull);
    });

    test('supports custom symbols, scale, and optional symbols', () {
      final basisPoints = PercentCodec(symbol: 'bp', scale: 10000);
      final optional = PercentCodec(requireSymbol: false);
      final spaced = PercentCodec(spaceBeforeSymbol: true);

      expect(basisPoints.format(0.0123), '123bp');
      expect(basisPoints.parse('123bp'), 0.0123);
      expect(optional.parse('12.5'), 0.125);
      expect(spaced.format(0.5), '50 %');
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
      expect(() => PercentCodec(symbol: ''), throwsA(isA<ArgumentError>()));
    });
  });
}

const _chineseUnits = NumeralUnitSet([
  NumeralUnit(1, ''),
  NumeralUnit(10000, '万'),
]);
