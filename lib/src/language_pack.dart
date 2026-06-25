import 'compact_codec.dart';
import 'rounding.dart';
import 'unit.dart';

/// A language pack supplies locale-specific unit data and number-word codecs.
abstract interface class NumeralLanguagePack {
  /// BCP 47-style locale identifier.
  String get locale;

  /// Compact unit data for this language.
  NumeralUnitSet get compactUnits;

  /// Creates a compact number codec using this pack's units.
  CompactCodec compact({
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
    bool compactOverflow = true,
  });
}
