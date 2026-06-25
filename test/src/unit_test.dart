import 'package:numeral/src/unit.dart';
import 'package:test/test.dart';

void main() {
  group('NumeralUnit', () {
    test('exposes parser tokens from symbol and aliases', () {
      const unit = NumeralUnit(1000, 'K', aliases: ['k', 'thousand']);

      expect(unit.tokens, ['K', 'k', 'thousand']);
    });

    test('formats suffix and prefix units with optional spacing', () {
      const suffix = NumeralUnit(1000, 'K');
      const spaced = NumeralUnit(1000, 'KB', space: true);
      const prefix = NumeralUnit(1, r'$', position: UnitPosition.prefix);
      const empty = NumeralUnit(1, '');

      expect(suffix.format('1.2'), '1.2K');
      expect(spaced.format('1.2'), '1.2 KB');
      expect(spaced.format('1.2', space: false), '1.2KB');
      expect(prefix.format('1.2'), r'$1.2');
      expect(prefix.format('1.2', space: true), r'$ 1.2');
      expect(empty.format('1.2'), '1.2');
    });
  });

  group('NumeralUnitSet', () {
    test('selects the largest matching unit by magnitude', () {
      const units = NumeralUnitSet([
        NumeralUnit(1, ''),
        NumeralUnit(1000, 'K'),
        NumeralUnit(1000000, 'M'),
      ]);

      expect(units.indexFor(0), 0);
      expect(units.indexFor(999), 0);
      expect(units.indexFor(1000), 1);
      expect(units.indexFor(999999), 1);
      expect(units.indexFor(1000000), 2);
    });
  });
}
