import 'decimal_codec.dart';
import '_utils.dart';
import 'numeral_codec.dart';
import 'rounding.dart';

/// Converts display-oriented currency values.
final class CurrencyCodec extends NumeralCodec<num> {
  /// Creates a currency codec.
  CurrencyCodec(
    this.symbol, {
    this.symbolOnRight = false,
    this.spaceBetweenSymbolAndNumber = false,
    bool grouping = true,
    String groupSeparator = ',',
    String decimalSeparator = '.',
    int minFractionDigits = 2,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = false,
    Rounding rounding = Rounding.halfUp,
  }) : _decimal = DecimalCodec(
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

  final DecimalCodec _decimal;

  @override
  String format(num value) {
    final special = formatSpecial(value);
    if (special != null) {
      final space = spaceBetweenSymbolAndNumber ? ' ' : '';
      return symbolOnRight ? '$special$space$symbol' : '$symbol$space$special';
    }

    final isNegative = value.isNegative;
    final number = _decimal.format(value.abs());
    final space = spaceBetweenSymbolAndNumber ? ' ' : '';
    final formatted =
        symbolOnRight ? '$number$space$symbol' : '$symbol$space$number';
    return isNegative ? '-$formatted' : formatted;
  }

  @override
  num parse(String input) {
    var trimmed = input.trim();
    final isNegative = trimmed.startsWith('-');
    if (isNegative) {
      trimmed = trimmed.substring(1).trim();
    }
    late final String number;

    if (symbolOnRight) {
      number = stripSuffix(trimmed, symbol, require: true);
    } else if (trimmed.startsWith(symbol)) {
      number = trimmed.substring(symbol.length).trim();
    } else {
      throw FormatException('Expected currency symbol "$symbol".', input);
    }

    final parsed = _decimal.parse(number);
    return isNegative ? -parsed : parsed;
  }
}
