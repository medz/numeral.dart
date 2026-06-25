import '../_utils.dart';
import '../codec.dart';
import '../rounding.dart';
import 'decimal.dart';

/// Converts ratios to and from percentage strings.
final class PercentCodec extends NumeralCodec<double> {
  /// Creates a percentage codec.
  PercentCodec({
    this.symbol = '%',
    this.scale = 100,
    this.spaceBeforeSymbol = false,
    this.requireSymbol = true,
    NumeralCodec<num>? style,
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
  }) : style = style ??
            DecimalCodec(
              grouping: false,
              decimalSeparator: decimalSeparator,
              minFractionDigits: minFractionDigits,
              maxFractionDigits: maxFractionDigits,
              trimTrailingZeros: trimTrailingZeros,
              rounding: rounding,
            ) {
    if (!scale.isFinite || scale == 0) {
      throw ArgumentError.value(scale, 'scale', 'Must be finite and non-zero.');
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

  /// Codec used for the numeric part before the percent symbol.
  final NumeralCodec<num> style;

  @override
  String format(num value) {
    final space = spaceBeforeSymbol ? ' ' : '';
    final special = formatSpecial(value);
    if (special != null) return '$special$space$symbol';

    return '${style.format(value * scale)}$space$symbol';
  }

  @override
  double parse(String input) {
    final number = stripSuffix(input, symbol, require: requireSymbol);
    return style.parse(number) / scale;
  }
}
