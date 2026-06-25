import 'dart:math' as math;

import 'rounding.dart';

String fixedDecimal(num value, int fractionDigits, Rounding rounding) {
  if (rounding == Rounding.halfUp) {
    return value.toStringAsFixed(fractionDigits);
  }

  if (fractionDigits == 0) {
    return value.truncate().toString();
  }

  final factor = math.pow(10, fractionDigits);
  final scaled = value * factor;
  final truncated = value.isNegative ? scaled.ceil() : scaled.floor();
  return (truncated / factor).toStringAsFixed(fractionDigits);
}

String normalizeFraction(
  String fraction,
  int minFractionDigits,
  bool trimTrailingZeros,
) {
  if (!trimTrailingZeros) return fraction;

  var normalized = fraction;
  while (normalized.length > minFractionDigits && normalized.endsWith('0')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}

String? formatSpecial(num value) {
  if (value.isNaN) return 'NaN';
  if (value == double.infinity) return '∞';
  if (value == double.negativeInfinity) return '-∞';
  return null;
}

num normalizeNum(num value) {
  if (!value.isFinite) return value;
  final integer = value.round();
  if ((value - integer).abs() <= 1e-9) return integer;
  return value;
}

String stripSuffix(String input, String suffix, {required bool require}) {
  final trimmed = input.trim();
  if (!trimmed.endsWith(suffix)) {
    if (!require) return trimmed;
    throw FormatException('Expected suffix "$suffix".', input);
  }
  return trimmed.substring(0, trimmed.length - suffix.length).trim();
}

void checkFractionDigits(int minFractionDigits, int maxFractionDigits) {
  if (minFractionDigits < 0) {
    throw ArgumentError.value(
      minFractionDigits,
      'minFractionDigits',
      'Must not be negative.',
    );
  }
  if (maxFractionDigits < 0) {
    throw ArgumentError.value(
      maxFractionDigits,
      'maxFractionDigits',
      'Must not be negative.',
    );
  }
  if (minFractionDigits > maxFractionDigits) {
    throw ArgumentError.value(
      minFractionDigits,
      'minFractionDigits',
      'Must not be greater than maxFractionDigits.',
    );
  }
}

void checkNotEmpty(String value, String name) {
  if (value.isEmpty) {
    throw ArgumentError.value(value, name, 'Must not be empty.');
  }
}
