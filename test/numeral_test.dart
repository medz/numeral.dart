import 'package:numeral/numeral.dart';
import 'package:test/test.dart';

void main() {
  group('public core barrel', () {
    test('exports codec protocol and shared models', () {
      const codec = _PassThroughCodec();
      final units = NumeralUnitSet([
        NumeralUnit(1, ''),
        NumeralUnit(1000, 'K'),
      ]);

      expect(codec.format(1), '1');
      expect(Rounding.truncate.name, 'truncate');
      expect(units.indexFor(1000), 1);
    });

    test('exports language and codec protocols', () {
      const language = _TestLanguage();

      expect(language, isA<NumeralLanguage>());
      expect(language.locale, 'x-test');
      expect(language.compact().format(1000), '1000');
      expect(_PassThroughCodec().encode(1), '1');
    });
  });
}

final class _PassThroughCodec extends NumeralCodec<num> {
  const _PassThroughCodec();

  @override
  String format(num value) => value.toString();

  @override
  num parse(String input) => num.parse(input);
}

final class _TestLanguage implements NumeralLanguage {
  const _TestLanguage();

  @override
  String get locale => 'x-test';

  @override
  NumeralUnitSet get compactUnits => const NumeralUnitSet([
        NumeralUnit(1, ''),
        NumeralUnit(1000, 'k'),
      ]);

  @override
  NumeralCodec<num> compact({
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
    bool compactOverflow = true,
  }) {
    return const _PassThroughCodec();
  }
}
