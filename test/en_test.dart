import 'package:numeral/en.dart' as en;
import 'package:numeral/numeral.dart';
import 'package:test/test.dart';

void main() {
  group('English language path', () {
    test('exposes an English language object', () {
      expect(en.en, isA<NumeralLanguage>());
      expect(en.en.locale, 'en');
      expect(en.en.compactUnits, same(en.englishCompactUnits));
    });

    test('formats and parses English compact numbers', () {
      final codec = en.compact(maxFractionDigits: 1);

      expect(codec.format(12345), '12.3K');
      expect(codec.parse('12.3K'), 12300);
      expect(codec.parse('3 million'), 3000000);
    });

    test('supports language object compact options', () {
      final codec = en.en.compact(maxFractionDigits: 0);

      expect(codec.format(999999), '1M');
    });

    test('defines English compact unit aliases', () {
      expect(en.englishCompactUnits.units[1].tokens, [
        'K',
        'k',
        'thousand',
      ]);
      expect(en.englishCompactUnits.indexFor(1000000), 2);
    });
  });
}
