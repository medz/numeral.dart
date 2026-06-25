import '../_utils.dart';
import '../codec.dart';
import '../rounding.dart';

/// Converts ordinary decimal numbers to and from display strings.
final class DecimalCodec extends NumeralCodec<num> {
  /// Creates a codec for ordinary decimal numbers.
  DecimalCodec({
    this.grouping = true,
    this.groupSeparator = ',',
    this.decimalSeparator = '.',
    this.minFractionDigits = 0,
    this.maxFractionDigits = 3,
    this.trimTrailingZeros = true,
    this.rounding = Rounding.halfUp,
  }) {
    checkFractionDigits(minFractionDigits, maxFractionDigits);
    checkNotEmpty(decimalSeparator, 'decimalSeparator');
    if (grouping) checkNotEmpty(groupSeparator, 'groupSeparator');
    if (grouping && groupSeparator == decimalSeparator) {
      throw ArgumentError.value(
        groupSeparator,
        'groupSeparator',
        'Must differ from decimalSeparator.',
      );
    }
  }

  /// Whether integer digits are grouped.
  final bool grouping;

  /// Separator inserted between grouped integer digits.
  final String groupSeparator;

  /// Separator used between integer and fraction digits.
  final String decimalSeparator;

  /// Minimum number of fraction digits to keep.
  final int minFractionDigits;

  /// Maximum number of fraction digits to keep.
  final int maxFractionDigits;

  /// Whether trailing zeros can be removed down to [minFractionDigits].
  final bool trimTrailingZeros;

  /// Rounding behavior for excess fraction digits.
  final Rounding rounding;

  static final _validNumberPattern = RegExp(
    r'^[+-]?(?:(?:\d+(?:\.\d*)?)|(?:\.\d+)|Infinity|NaN)(?:[eE][+-]?\d+)?$',
  );

  @override
  String format(num value) {
    final special = formatSpecial(value);
    if (special != null) return special;

    final fixed = fixedDecimal(value, maxFractionDigits, rounding);
    final parts = fixed.split('.');
    final integer = grouping ? _groupInteger(parts.first) : parts.first;
    final fraction = parts.length == 1
        ? ''
        : normalizeFraction(
            parts.last,
            minFractionDigits,
            trimTrailingZeros,
          );

    if (fraction.isEmpty) return integer;
    return '$integer$decimalSeparator$fraction';
  }

  @override
  num parse(String input) {
    final normalized = _normalizeNumberInput(input);
    return num.parse(normalized);
  }

  String _normalizeNumberInput(String input) {
    var normalized = input.trim();
    if (normalized.isEmpty) {
      throw FormatException('Expected a number.', input);
    }

    normalized = switch (normalized) {
      '∞' => 'Infinity',
      '+∞' => 'Infinity',
      '-∞' => '-Infinity',
      _ => normalized,
    };

    if (grouping) {
      _validateGrouping(normalized, input);
      normalized = normalized.replaceAll(groupSeparator, '');
    }
    if (decimalSeparator != '.') {
      normalized = normalized.replaceAll(decimalSeparator, '.');
    }

    if (!_validNumberPattern.hasMatch(normalized)) {
      throw FormatException('Expected a number.', input);
    }

    return normalized;
  }

  void _validateGrouping(String normalized, String input) {
    if (!normalized.contains(groupSeparator)) return;

    final exponentIndex = _exponentIndex(normalized);
    final mantissa =
        exponentIndex < 0 ? normalized : normalized.substring(0, exponentIndex);
    if (exponentIndex >= 0 &&
        normalized.substring(exponentIndex + 1).contains(groupSeparator)) {
      throw FormatException('Invalid digit grouping.', input);
    }

    final decimalIndex = mantissa.indexOf(decimalSeparator);
    var integer =
        decimalIndex < 0 ? mantissa : mantissa.substring(0, decimalIndex);
    if (decimalIndex >= 0 &&
        mantissa
            .substring(decimalIndex + decimalSeparator.length)
            .contains(groupSeparator)) {
      throw FormatException('Invalid digit grouping.', input);
    }

    if (integer.startsWith('-') || integer.startsWith('+')) {
      integer = integer.substring(1);
    }

    if (!integer.contains(groupSeparator)) {
      throw FormatException('Invalid digit grouping.', input);
    }

    final groups = integer.split(groupSeparator);
    if (groups.isEmpty ||
        groups.first.isEmpty ||
        groups.first.length > 3 ||
        !_isAsciiDigits(groups.first)) {
      throw FormatException('Invalid digit grouping.', input);
    }

    for (final group in groups.skip(1)) {
      if (group.length != 3 || !_isAsciiDigits(group)) {
        throw FormatException('Invalid digit grouping.', input);
      }
    }
  }

  int _exponentIndex(String input) {
    final lower = input.indexOf('e');
    final upper = input.indexOf('E');
    if (lower < 0) return upper;
    if (upper < 0) return lower;
    return lower < upper ? lower : upper;
  }

  bool _isAsciiDigits(String input) {
    for (final codeUnit in input.codeUnits) {
      if (codeUnit < 48 || codeUnit > 57) return false;
    }
    return true;
  }

  String _groupInteger(String integer) {
    final sign = integer.startsWith('-') || integer.startsWith('+')
        ? integer.substring(0, 1)
        : '';
    final digits = sign.isEmpty ? integer : integer.substring(1);
    final buffer = StringBuffer(sign);
    final firstGroup = digits.length % 3;

    if (firstGroup != 0) {
      buffer.write(digits.substring(0, firstGroup));
      if (digits.length > firstGroup) buffer.write(groupSeparator);
    }

    for (var index = firstGroup; index < digits.length; index += 3) {
      if (index != firstGroup) buffer.write(groupSeparator);
      buffer.write(digits.substring(index, index + 3));
    }

    return buffer.toString();
  }
}
