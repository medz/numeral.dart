import 'package:numeral/src/codec/bytes.dart';
import 'package:numeral/src/codec/decimal.dart';
import 'package:numeral/src/unit.dart';
import 'package:test/test.dart';

void main() {
  group('BytesCodec', () {
    test('formats decimal byte sizes', () {
      final codec = BytesCodec(maxFractionDigits: 1);

      expect(codec.format(999), '999 B');
      expect(codec.format(1000), '1 KB');
      expect(codec.format(1500), '1.5 KB');
      expect(codec.format(2500000), '2.5 MB');
    });

    test('formats binary byte sizes', () {
      final codec = BytesCodec.binary(maxFractionDigits: 1);

      expect(codec.format(1024), '1 KiB');
      expect(codec.format(1536), '1.5 KiB');
      expect(codec.format(1048576), '1 MiB');
    });

    test('parses byte sizes directly to int', () {
      final decimal = BytesCodec();
      final binary = BytesCodec.binary();

      expect(decimal.parse('1 KB'), 1000);
      expect(decimal.parse('1.5 MB'), 1500000);
      expect(decimal.parse('1.5 megabytes'), 1500000);
      expect(binary.parse('1.5 KiB'), 1536);
      expect(binary.tryParse('0.1 B'), isNull);
      expect(decimal.tryParse('∞'), isNull);
      expect(decimal.tryParse('NaN B'), isNull);
    });

    test('rejects non-whole byte counts when formatting', () {
      final codec = BytesCodec();

      expect(() => codec.format(1.2), throwsA(isA<ArgumentError>()));
      expect(
        () => codec.format(double.infinity),
        throwsA(isA<ArgumentError>()),
      );
      expect(() => codec.format(double.nan), throwsA(isA<ArgumentError>()));
    });

    test('can use a custom number style', () {
      final codec = BytesCodec.binary(
        style: DecimalCodec(
          grouping: false,
          decimalSeparator: ',',
          maxFractionDigits: 1,
        ),
      );

      expect(codec.format(1536), '1,5 KiB');
      expect(codec.parse('1,5 KiB'), 1536);
    });

    test('supports custom byte unit sets', () {
      final codec = BytesCodec(
        unitSet: const NumeralUnitSet([
          NumeralUnit(1, 'B', space: true),
          NumeralUnit(2, 'word', aliases: ['words'], space: true),
        ]),
      );

      expect(codec.format(8), '4 word');
      expect(codec.parse('4 words'), 8);
    });

    test('round-trips custom prefix byte units', () {
      final codec = BytesCodec(
        unitSet: const NumeralUnitSet([
          NumeralUnit(1, 'B', space: true),
          NumeralUnit(
            1000,
            'k',
            aliases: ['kilo'],
            position: UnitPosition.prefix,
            space: true,
          ),
        ]),
        maxFractionDigits: 1,
      );

      expect(codec.format(1500), 'k 1.5');
      expect(codec.parse('k 1.5'), 1500);
      expect(codec.parse('kilo 1.5'), 1500);
    });

    test('rejects empty unit sets', () {
      expect(
        () => BytesCodec(unitSet: const NumeralUnitSet([])),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects malformed unit sets', () {
      expect(
        () => BytesCodec(
          unitSet: const NumeralUnitSet([
            NumeralUnit(1, 'B'),
            NumeralUnit(0, 'KB'),
          ]),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
