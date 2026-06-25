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

    test('rejects empty unit sets', () {
      expect(
        () => NumeralUnitMatcher(const NumeralUnitSet([])),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
