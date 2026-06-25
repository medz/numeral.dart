import '../_utils.dart';
import '../codec.dart';
import '../rounding.dart';
import 'decimal.dart';

/// Converts display-oriented currency values.
final class CurrencyCodec extends NumeralCodec<num> {
  /// Creates a currency codec.
  CurrencyCodec(
    this.symbol, {
    this.symbolOnRight = false,
    this.spaceBetweenSymbolAndNumber = false,
    NumeralCodec<num>? style,
    bool grouping = true,
    String groupSeparator = ',',
    String decimalSeparator = '.',
    int minFractionDigits = 2,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = false,
    Rounding rounding = Rounding.halfUp,
  }) : style = style ??
            DecimalCodec(
              grouping: grouping,
              groupSeparator: groupSeparator,
              decimalSeparator: decimalSeparator,
              minFractionDigits: minFractionDigits,
              maxFractionDigits: maxFractionDigits,
              trimTrailingZeros: trimTrailingZeros,
              rounding: rounding,
            ) {
    checkNotEmpty(symbol, 'symbol');
  }

  /// Currency symbol.
  final String symbol;

  /// Whether [symbol] appears after the number.
  final bool symbolOnRight;

  /// Whether a space is inserted between symbol and number.
  final bool spaceBetweenSymbolAndNumber;

  /// Codec used for the numeric part inside the currency string.
  final NumeralCodec<num> style;

  @override
  String format(num value) {
    final special = formatSpecial(value);
    final numberPart = special ?? style.format(value);
    return _formatNumberPart(numberPart);
  }

  String _formatNumberPart(String numberPart) {
    final space = spaceBetweenSymbolAndNumber ? ' ' : '';
    if (!symbolOnRight && numberPart.startsWith('-')) {
      return '-$symbol$space${numberPart.substring(1)}';
    }

    final formatted =
        symbolOnRight ? '$numberPart$space$symbol' : '$symbol$space$numberPart';
    return formatted;
  }

  @override
  num parse(String input) {
    var trimmed = input.trim();
    final isNegative = trimmed.startsWith('-');
    if (isNegative) {
      trimmed = trimmed.substring(1).trim();
    }
    late final String numberPart;

    if (symbolOnRight) {
      numberPart = stripSuffix(trimmed, symbol, require: true);
    } else if (trimmed.startsWith(symbol)) {
      numberPart = trimmed.substring(symbol.length).trim();
    } else {
      throw FormatException('Expected currency symbol "$symbol".', input);
    }

    final parsed = style.parse(numberPart);
    if (isNegative &&
        (numberPart.trim().startsWith('+') || parsed.isNegative)) {
      throw FormatException(
        'Currency value must not contain multiple signs.',
        input,
      );
    }
    return isNegative ? -parsed : parsed;
  }
}
