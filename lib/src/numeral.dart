library numeral;

import 'numeral_unit.dart';

extension Numeral<T extends num> on T {
  /// Global configuration for numeral formatting default [digits].
  static int digits = 3;

  /// Global configuration for numeral formatting default unit [builder].
  static String Function(NumeralUnit) builder = (unit) => unit.value;

  /// Parsing [T] to formated [String].
  ///
  /// ```dart
  /// 1000.numeral(); // -> 1K
  /// ```
  /// If [digits] is not specified, it defaults to 3.
  String numeral({int? digits = 3, String Function(NumeralUnit)? builder}) {
    final (value, unit) = toNumeral;
    final cleaned = value.toStringAsFixed(digits.orDefault).cleaned;
    final suffix = builder.orDefault(unit);

    return '$cleaned$suffix';
  }

  /// Parsing [T] to formated [String].
  ///
  /// The getter [beautiful] is an alias for [numeral] with default [digits]
  /// and [builder].
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

extension on int? {
  int get orDefault {
    return switch (this) {
      int value => value,
      _ => Numeral.digits,
    };
  }
}
