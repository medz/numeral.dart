import 'package:numeral/src/unit.dart';
import 'package:numeral/src/unit_matcher.dart';
import 'package:test/test.dart';

void main() {
  group('NumeralUnitMatcher', () {
    test('matches the longest unit suffix case-insensitively', () {
      final matcher = NumeralUnitMatcher(
        const NumeralUnitSet([
          NumeralUnit(1, 'B'),
          NumeralUnit(1000, 'KB', aliases: ['kb', 'kilobyte', 'kilobytes']),
        ]),
      );

      final match = matcher.match('1 KB');

      expect(match.number, '1');
      expect(match.unit.scale, 1000);
      expect(matcher.match('1 kilobytes').number, '1');
      expect(matcher.match('1 KILOBYTE').unit.scale, 1000);
    });

    test('matches prefix units by position', () {
      final matcher = NumeralUnitMatcher(
        const NumeralUnitSet([
          NumeralUnit(1, ''),
          NumeralUnit(
            100,
            'x',
            aliases: ['times'],
            position: UnitPosition.prefix,
            space: true,
          ),
        ]),
      );

      final match = matcher.match('x 1.5');

      expect(match.number, '1.5');
      expect(match.unit.scale, 100);
      expect(matcher.match('TIMES 2').number, '2');
    });

    test('falls back to the first unit when no suffix matches', () {
      final matcher = NumeralUnitMatcher(
        const NumeralUnitSet([
          NumeralUnit(1, ''),
          NumeralUnit(1000, 'K'),
        ]),
      );

      final match = matcher.match('123');

      expect(match.number, '123');
      expect(match.unit.scale, 1);
    });

    test('selects units by magnitude from the validated unit set', () {
      final matcher = NumeralUnitMatcher(
        const NumeralUnitSet([
          NumeralUnit(1, ''),
          NumeralUnit(1000, 'K'),
          NumeralUnit(1000000, 'M'),
        ]),
      );

      expect(matcher.length, 3);
      expect(matcher.indexFor(0), 0);
      expect(matcher.indexFor(999), 0);
      expect(matcher.indexFor(1000), 1);
      expect(matcher.indexFor(999999), 1);
      expect(matcher.indexFor(1000000), 2);
      expect(matcher.unitFor(1000000).symbol, 'M');
      expect(matcher.unitAt(1).symbol, 'K');
    });

    test('keeps a stable snapshot of the validated unit set', () {
      final units = [
        const NumeralUnit(1, ''),
        const NumeralUnit(1000, 'K'),
      ];
      final matcher = NumeralUnitMatcher(NumeralUnitSet(units));

      units.add(const NumeralUnit(1000000, 'M'));

      expect(matcher.length, 2);
      expect(matcher.unitFor(1000000).symbol, 'K');
      expect(matcher.match('1M').unit.scale, 1);
    });

    test('rejects empty unit sets', () {
      expect(
        () => NumeralUnitMatcher(const NumeralUnitSet([])),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects invalid unit scales', () {
      expect(
        () => NumeralUnitMatcher(
          const NumeralUnitSet([
            NumeralUnit(0, ''),
          ]),
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => NumeralUnitMatcher(
          const NumeralUnitSet([
            NumeralUnit(1, ''),
            NumeralUnit(double.infinity, 'K'),
          ]),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects non-ascending unit scales', () {
      expect(
        () => NumeralUnitMatcher(
          const NumeralUnitSet([
            NumeralUnit(1000, 'K'),
            NumeralUnit(1, ''),
          ]),
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => NumeralUnitMatcher(
          const NumeralUnitSet([
            NumeralUnit(1, ''),
            NumeralUnit(1000, 'K'),
            NumeralUnit(1000, 'thousand'),
          ]),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects blank and ambiguous unit tokens', () {
      expect(
        () => NumeralUnitMatcher(
          const NumeralUnitSet([
            NumeralUnit(1, ''),
            NumeralUnit(1000, ' '),
          ]),
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => NumeralUnitMatcher(
          const NumeralUnitSet([
            NumeralUnit(1, 'B'),
            NumeralUnit(1000, 'KB', aliases: ['b']),
          ]),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
