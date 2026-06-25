import 'package:numeral/numeral.dart';
import 'package:test/test.dart';

void main() {
  group('public barrel', () {
    test('exports core codecs and models', () {
      final units = NumeralUnitSet([
        NumeralUnit(1, ''),
        NumeralUnit(1000, 'K'),
      ]);

      expect(DecimalCodec(maxFractionDigits: 1).format(1234.5), '1,234.5');
      expect(CompactCodec(unitSet: units).format(1200), '1.2K');
      expect(PercentCodec().format(0.12), '12%');
      expect(BytesCodec.binary().format(1024), '1 KiB');
      expect(CurrencyCodec(r'$').format(1), r'$1.00');
      expect(Rounding.truncate.name, 'truncate');
      expect(units.indexFor(1000), 1);
    });

    test('exports language and codec protocols', () {
      const language = _TestLanguage();

      expect(language, isA<NumeralLanguage>());
      expect(language.locale, 'x-test');
      expect(language.compact().format(1000), '1k');
      expect(_PassThroughCodec().encode(1), '1');
    });
  });
}

final class _PassThroughCodec extends NumeralCodec<num> {
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
  CompactCodec compact({
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
    bool compactOverflow = true,
  }) {
    return CompactCodec(
      unitSet: compactUnits,
      decimalSeparator: decimalSeparator,
      minFractionDigits: minFractionDigits,
      maxFractionDigits: maxFractionDigits,
      trimTrailingZeros: trimTrailingZeros,
      rounding: rounding,
      compactOverflow: compactOverflow,
    );
  }
}
