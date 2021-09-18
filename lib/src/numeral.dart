import 'constants.dart';
import 'parser.dart';

class Numeral {
  final num _number;

  Numeral._(this._number);

  /// Create [Numeral] class.
  ///
  /// The Factory create a [Numeral] class instance.
  ///
  /// [number] is num [Type].
  ///
  /// return [Numeral] instance.
  factory Numeral(num number) {
    assert(
        number is num, 'The data to be processed must be passed in a [num].');

    return Numeral._(number);
  }

  /// Get a [number] for double value.
  ///
  /// Get the [_number] to [double] Type value.
  double get number => _number.toDouble();

  /// Format [number] to beautiful [String].
  ///
  /// E.g:
  /// ```dart
  /// Numeral(1000).value(); // -> 1K
  /// ```
  ///
  /// return a [String] type.
  String value({int fractionDigits = DEFAULT_FRACTION_DIGITS}) {
    final NumeralParsedValue parsed = numeralParser(number);

    return _removeEndsZero(parsed.value.toStringAsFixed(fractionDigits)) +
        parsed.suffix;
  }

  /// Remove value ends with zero.
  ///
  /// Remove formated value ends with zero,
  /// replace to zero string.
  ///
  /// [value] type is [String].
  ///
  /// return a [String] type.
  String _removeEndsZero(String value) {
    if (value.indexOf('.') == -1) {
      return value;
    }

    if (value.endsWith('.')) {
      return value.substring(0, value.length - 1);
    } else if (value.endsWith('0')) {
      return _removeEndsZero(value.substring(0, value.length - 1));
    }

    return value;
  }

  /// Get formated value.
  ///
  /// Get the [value] function value.
  ///
  /// return a [String] type.
  @override
  String toString() => value();
}
