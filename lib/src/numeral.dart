import 'numeral_unit.dart';

extension Numeral<T extends num> on T {
  /// Default unit for numeral formatting builder.
  static String defaultBuilder(NumeralUnit unit) => unit.value;

  /// Global configuration for numeral formatting default [digits].
  static int digits = 3;

  /// Global configuration for numeral rounded defaults to false.
  /// Example:
  /// ```dart
  /// Numeral.digits = 1
  /// Numeral.rounded = true
  /// 1050.numeral(); // -> 1.1K;
  /// ```
  /// ---------------------------
  /// ```dart
  /// Numeral.digits = 1
  /// Numeral.rounded = false
  /// 1050.numeral(); // -> 1K;
  /// ```
  static bool rounded = false;

  /// Global configuration for numeral formatting default unit [builder].
  static String Function(NumeralUnit) builder = defaultBuilder;

  /// Parsing [T] to formated [String].
  ///
  /// ```dart
  /// 1050.numeral(digits: 1, rounded: true); // -> 1.1K;
  /// ```
  /// ---------------------------
  /// ```dart
  /// 1050.numeral(digits: 1, rounded: false); // -> 1K;
  /// ```
  /// If [digits] is not specified, it defaults to 3.
  /// If [rounded] is not specified, it defaults to false.
  String numeral(
      {int? digits, bool? rounded, String Function(NumeralUnit)? builder}) {
    final (value, unit) = toNumeral;
    rounded ??= Numeral.rounded;
    digits ??= Numeral.digits;
    final cleaned = (rounded
            ? value.toStringAsFixed(digits)
            : value.toStringAsFixedNotRound(digits))
        .cleaned;
    final suffix = builder.orDefault(unit);

    return '$cleaned$suffix';
  }

  /// Parsing [T] to formated [String].
  ///
  /// The getter [beautiful] is an alias for [numeral] with default [digits],
  /// [rounded] and [builder].
  ///
  /// ```dart
  /// 1000.beautiful; // -> 1K
  /// ```
  String get beautiful => numeral();
}

extension<T extends num> on T {
  (num, NumeralUnit) get toNumeral {
    return switch (abs()) {
      >= 1000000000000 => (this / 1000000000000, NumeralUnit.trillion),
      >= 1000000000 => (this / 1000000000, NumeralUnit.billion),
      >= 1000000 => (this / 1000000, NumeralUnit.million),
      >= 1000 => (this / 1000, NumeralUnit.thousand),
      _ => (this, NumeralUnit.less),
    };
  }

  String toStringAsFixedNotRound(int fractionDigits) {
    int integerValue = toInt();
    String integerPart = integerValue.toString();
    if (fractionDigits == 0) return integerPart;

    // Here we are ensuring the integer part to conserve the sign of the number
    // because in case the number is between -1 and 0, the integer part will be 0
    // and 0 is not negative, so we need to add the sign to the integer part
    if (this < 0 && !integerPart.startsWith('-')) {
      integerPart = '-$integerPart';
    }

    // Avoid using the following variants to get the decimal part because implies rounding, somehow dart does some floating point rounding for some values:
    // num decimalValue = this % 1;
    // num decimalValue = this - integerValue;

    // Instead use string splitting which ensure we get the exact decimal part without rounding
    final splitParts = toString().split('.');
    if (splitParts.length == 1) return integerPart;

    String decimalPart = splitParts.lastOrNull ?? '';
    if (decimalPart.length >= fractionDigits) {
      decimalPart = decimalPart.substring(0, fractionDigits);
    } else {
      decimalPart =
          decimalPart.padRight(fractionDigits - decimalPart.length, '0');
    }
    return '$integerPart.$decimalPart';
  }
}

extension on String {
  String get cleaned {
    return switch (this) {
      String value when value.endsWith('.') =>
        value.substring(0, value.length - 1),
      String value when value.endsWith('0') && contains('.') =>
        value.substring(0, value.length - 1).cleaned,
      _ => this,
    };
  }
}

extension on String Function(NumeralUnit)? {
  String Function(NumeralUnit) get orDefault {
    return switch (this) {
      String Function(NumeralUnit) builder => builder,
      _ => Numeral.builder,
    };
  }
}
