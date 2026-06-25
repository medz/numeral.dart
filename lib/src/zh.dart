import 'compact_codec.dart';
import 'language_pack.dart';
import 'rounding.dart';
import 'unit.dart';
import 'zh_cardinal_codec.dart';

/// Simplified Chinese numerals language pack.
const zh = ChineseNumerals();

/// Simplified Chinese compact units: `万`, `亿`, `兆`.
const chineseCompactUnits = NumeralUnitSet([
  NumeralUnit(1, ''),
  NumeralUnit(10000, '万'),
  NumeralUnit(100000000, '亿'),
  NumeralUnit(1000000000000, '兆'),
]);

/// Creates a Simplified Chinese compact number codec.
CompactCodec compact({
  String decimalSeparator = '.',
  int minFractionDigits = 0,
  int maxFractionDigits = 2,
  bool trimTrailingZeros = true,
  Rounding rounding = Rounding.halfUp,
  bool compactOverflow = true,
}) {
  return zh.compact(
    decimalSeparator: decimalSeparator,
    minFractionDigits: minFractionDigits,
    maxFractionDigits: maxFractionDigits,
    trimTrailingZeros: trimTrailingZeros,
    rounding: rounding,
    compactOverflow: compactOverflow,
  );
}

/// Creates a Simplified Chinese cardinal number codec.
ChineseCardinalCodec cardinal() => zh.cardinal();

/// Simplified Chinese numerals language pack.
final class ChineseNumerals implements NumeralLanguagePack {
  /// Creates a Simplified Chinese numerals language pack.
  const ChineseNumerals();

  @override
  String get locale => 'zh';

  @override
  NumeralUnitSet get compactUnits => chineseCompactUnits;

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

  /// Creates a Simplified Chinese cardinal number codec.
  ChineseCardinalCodec cardinal() => const ChineseCardinalCodec();
}
