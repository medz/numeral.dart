import 'package:numeral/en.dart' as en;
import 'package:numeral/src/language.dart';
import 'package:test/test.dart';

void main() {
  group('NumeralLanguage', () {
    test('describes locale-specific compact units and codecs', () {
      final language = en.en;

      expect(language, isA<NumeralLanguage>());
      expect(language.locale, 'en');
      expect(language.compactUnits, same(en.englishCompactUnits));
      expect(language.compact(maxFractionDigits: 1).format(12345), '12.3K');
    });
  });
}
