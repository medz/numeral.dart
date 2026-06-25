import 'package:numeral/src/codec/compact.dart';
import 'package:numeral/src/codec/decimal.dart';
import 'package:numeral/src/unit.dart';
import 'package:test/test.dart';

void main() {
  group('CompactCodec', () {
    test('formats compact numbers', () {
      final codec = CompactCodec(
        unitSet: _westernUnits,
        maxFractionDigits: 1,
      );

      expect(codec.format(1234), '1.2K');
      expect(codec.format(1234567), '1.2M');
      expect(codec.format(-1234567), '-1.2M');
      expect(codec.format(double.infinity), '∞');
    });

    test('moves rounded overflow to the next unit', () {
      final codec = CompactCodec(
        unitSet: _westernUnits,
        maxFractionDigits: 0,
      );

      expect(codec.format(999999), '1M');
      expect(codec.format(999999999), '1B');
    });

    test('can keep rounded overflow in the current unit', () {
      final codec = CompactCodec(
        unitSet: _westernUnits,
        maxFractionDigits: 0,
        compactOverflow: false,
      );

      expect(codec.format(999999), '1000K');
    });

    test('supports non-western unit scales', () {
      final codec = CompactCodec(
        unitSet: _chineseUnits,
        maxFractionDigits: 2,
      );

      expect(codec.format(1234567), '123.46万');
      expect(codec.format(120000000), '1.2亿');
    });

    test('parses compact suffixes directly to num', () {
      final codec = CompactCodec(unitSet: _westernUnits);
      final zhCompact = CompactCodec(unitSet: _chineseUnits);

      expect(codec.parse('1.2K'), 1200);
      expect(codec.parse('3 million'), 3000000);
      expect(codec.parse('-1.5B'), -1500000000);
      expect(zhCompact.parse('3.5万'), 35000);
      expect(codec.tryParse('abc'), isNull);
    });

    test('round-trips prefix compact units', () {
      final codec = CompactCodec(
        unitSet: _prefixUnits,
        maxFractionDigits: 1,
      );

      expect(codec.format(1500), 'k 1.5');
      expect(codec.parse('k 1.5'), 1500);
      expect(codec.parse('kilo 1.5'), 1500);
    });

    test('can use a custom number style', () {
      final codec = CompactCodec(
        unitSet: _westernUnits,
        style: DecimalCodec(
          grouping: false,
          decimalSeparator: ',',
          maxFractionDigits: 1,
        ),
      );

      expect(codec.format(1234), '1,2K');
      expect(codec.parse('1,2K'), 1200);
    });

    test('rejects empty unit sets', () {
      expect(
        () => CompactCodec(unitSet: const NumeralUnitSet([])),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects malformed unit sets', () {
      expect(
        () => CompactCodec(
          unitSet: const NumeralUnitSet([
            NumeralUnit(1000, 'K'),
            NumeralUnit(1, ''),
          ]),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}

const _westernUnits = NumeralUnitSet([
  NumeralUnit(1, ''),
  NumeralUnit(1000, 'K', aliases: ['k', 'thousand']),
  NumeralUnit(1000000, 'M', aliases: ['m', 'million']),
  NumeralUnit(1000000000, 'B', aliases: ['b', 'billion']),
]);

const _chineseUnits = NumeralUnitSet([
  NumeralUnit(1, ''),
  NumeralUnit(10000, '万'),
  NumeralUnit(100000000, '亿'),
]);

const _prefixUnits = NumeralUnitSet([
  NumeralUnit(1, ''),
  NumeralUnit(
    1000,
    'k',
    aliases: ['kilo'],
    position: UnitPosition.prefix,
    space: true,
  ),
]);
