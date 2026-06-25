import 'decimal_codec.dart';
import 'internal.dart';
import 'numeral_codec.dart';
import 'rounding.dart';

/// Converts ratios to and from percentage strings.
final class PercentCodec extends NumeralCodec<double> {
  /// Creates a percentage codec.
  PercentCodec({
    this.symbol = '%',
    this.scale = 100,
    this.spaceBeforeSymbol = false,
    this.requireSymbol = true,
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
  }) : _decimal = DecimalCodec(
          grouping: false,
          decimalSeparator: decimalSeparator,
          minFractionDigits: minFractionDigits,
          maxFractionDigits: maxFractionDigits,
          trimTrailingZeros: trimTrailingZeros,
          rounding: rounding,
        ) {
    if (scale == 0) {
      throw ArgumentError.value(scale, 'scale', 'Must not be zero.');
    }
    checkNotEmpty(symbol, 'symbol');
  }

  /// Symbol appended after the formatted number.
  final String symbol;

  /// Multiplier applied when formatting and parsing.
  final num scale;

  /// Whether a space is inserted before [symbol].
  final bool spaceBeforeSymbol;

  /// Whether parsing requires [symbol].
  final bool requireSymbol;

  final DecimalCodec _decimal;

  @override
  String format(num value) {
    final special = formatSpecial(value);
    if (special != null) return special;

    final space = spaceBeforeSymbol ? ' ' : '';
    return '${_decimal.format(value * scale)}$space$symbol';
  }

  @override
  double parse(String input) {
    final number = stripSuffix(input, symbol, require: requireSymbol);
    return _decimal.parse(number) / scale;
  }
}
