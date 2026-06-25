import 'dart:math' as math;

import 'rounding.dart';

String fixedDecimal(num value, int fractionDigits, Rounding rounding) {
  String formatted;
  if (rounding == Rounding.halfUp) {
    formatted = value.toStringAsFixed(fractionDigits);
  } else if (fractionDigits == 0) {
    formatted = value.truncate().toString();
  } else {
    final factor = math.pow(10, fractionDigits);
    final scaled = value * factor;
    final truncated = value.isNegative ? scaled.ceil() : scaled.floor();
    formatted = (truncated / factor).toStringAsFixed(fractionDigits);
  }

  return stripNegativeZero(formatted);
}

String stripNegativeZero(String value) {
  if (!value.startsWith('-')) return value;

  for (var index = 1; index < value.length; index += 1) {
    final codeUnit = value.codeUnitAt(index);
    if (codeUnit != 46 && codeUnit != 48) return value;
  }
  return value.substring(1);
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
  const maxSupportedFractionDigits = 20;

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
  if (maxFractionDigits > maxSupportedFractionDigits) {
    throw ArgumentError.value(
      maxFractionDigits,
      'maxFractionDigits',
      'Must not be greater than $maxSupportedFractionDigits.',
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
