/// Fluent formatting extensions for numeric values.
///
/// ```dart
/// import 'package:numeral/extension.dart';
///
/// 12345.compact(); // 12.35K
/// 0.1234.percent(maxFractionDigits: 1); // 12.3%
/// ```
library;

import 'en.dart' as en;
import 'numeral.dart';

export 'numeral.dart';

/// Fluent formatting helpers for [num] values.
extension NumeralNumExtension on num {
  /// Formats this value with an existing codec.
  String formatWith<T extends num>(NumeralCodec<T> codec) => codec.format(this);

  /// Formats this value as an ordinary decimal number.
  String decimal({
    bool grouping = true,
    String groupSeparator = ',',
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 3,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
  }) {
    return DecimalCodec(
      grouping: grouping,
      groupSeparator: groupSeparator,
      decimalSeparator: decimalSeparator,
      minFractionDigits: minFractionDigits,
      maxFractionDigits: maxFractionDigits,
      trimTrailingZeros: trimTrailingZeros,
      rounding: rounding,
    ).format(this);
  }

  /// Formats this value using compact units.
  ///
  /// Defaults to English compact units. Pass a different [unitSet] for another
  /// language or domain.
  String compact({
    NumeralUnitSet unitSet = en.englishCompactUnits,
    NumeralCodec<num>? style,
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
    bool compactOverflow = true,
  }) {
    return CompactCodec(
      unitSet: unitSet,
      style: style,
      decimalSeparator: decimalSeparator,
      minFractionDigits: minFractionDigits,
      maxFractionDigits: maxFractionDigits,
      trimTrailingZeros: trimTrailingZeros,
      rounding: rounding,
      compactOverflow: compactOverflow,
    ).format(this);
  }

  /// Formats this value as a percentage ratio.
  String percent({
    String symbol = '%',
    num scale = 100,
    bool spaceBeforeSymbol = false,
    bool requireSymbol = true,
    NumeralCodec<num>? style,
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
  }) {
    return PercentCodec(
      symbol: symbol,
      scale: scale,
      spaceBeforeSymbol: spaceBeforeSymbol,
      requireSymbol: requireSymbol,
      style: style,
      decimalSeparator: decimalSeparator,
      minFractionDigits: minFractionDigits,
      maxFractionDigits: maxFractionDigits,
      trimTrailingZeros: trimTrailingZeros,
      rounding: rounding,
    ).format(this);
  }

  /// Formats this value as a byte size.
  String bytes({
    bool binary = false,
    NumeralUnitSet? unitSet,
    bool? spaceBeforeUnit,
    NumeralCodec<num>? style,
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
  }) {
    return BytesCodec(
      unitSet: unitSet ?? (binary ? binaryByteUnits : decimalByteUnits),
      spaceBeforeUnit: spaceBeforeUnit,
      style: style,
      decimalSeparator: decimalSeparator,
      minFractionDigits: minFractionDigits,
      maxFractionDigits: maxFractionDigits,
      trimTrailingZeros: trimTrailingZeros,
      rounding: rounding,
    ).format(this);
  }

  /// Formats this value as a display-oriented currency string.
  String currency(
    String symbol, {
    bool symbolOnRight = false,
    bool spaceBetweenSymbolAndNumber = false,
    NumeralCodec<num>? style,
    bool grouping = true,
    String groupSeparator = ',',
    String decimalSeparator = '.',
    int minFractionDigits = 2,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = false,
    Rounding rounding = Rounding.halfUp,
  }) {
    return CurrencyCodec(
      symbol,
      symbolOnRight: symbolOnRight,
      spaceBetweenSymbolAndNumber: spaceBetweenSymbolAndNumber,
      style: style,
      grouping: grouping,
      groupSeparator: groupSeparator,
      decimalSeparator: decimalSeparator,
      minFractionDigits: minFractionDigits,
      maxFractionDigits: maxFractionDigits,
      trimTrailingZeros: trimTrailingZeros,
      rounding: rounding,
    ).format(this);
  }
}
