/// English numerals language pack.
library;

import 'src/compact_codec.dart';
import 'src/language_pack.dart';
import 'src/rounding.dart';
import 'src/unit.dart';

/// English numerals language pack.
const en = EnglishNumerals();

/// English compact units: `K`, `M`, `B`, `T`, `P`.
const englishCompactUnits = NumeralUnitSet([
  NumeralUnit(1, ''),
  NumeralUnit(1000, 'K', aliases: ['k', 'thousand']),
  NumeralUnit(1000000, 'M', aliases: ['m', 'million']),
  NumeralUnit(1000000000, 'B', aliases: ['b', 'billion']),
  NumeralUnit(1000000000000, 'T', aliases: ['t', 'trillion']),
  NumeralUnit(1000000000000000, 'P', aliases: ['p', 'quadrillion']),
]);

/// Creates an English compact number codec.
CompactCodec compact({
  String decimalSeparator = '.',
  int minFractionDigits = 0,
  int maxFractionDigits = 2,
  bool trimTrailingZeros = true,
  Rounding rounding = Rounding.halfUp,
  bool compactOverflow = true,
}) {
  return en.compact(
    decimalSeparator: decimalSeparator,
    minFractionDigits: minFractionDigits,
    maxFractionDigits: maxFractionDigits,
    trimTrailingZeros: trimTrailingZeros,
    rounding: rounding,
    compactOverflow: compactOverflow,
  );
}

/// English numerals language pack.
final class EnglishNumerals implements NumeralLanguagePack {
  /// Creates an English numerals language pack.
  const EnglishNumerals();

  @override
  String get locale => 'en';

  @override
  NumeralUnitSet get compactUnits => englishCompactUnits;

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
