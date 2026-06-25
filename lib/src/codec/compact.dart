import '../_utils.dart';
import '../codec.dart';
import '../rounding.dart';
import '../unit.dart';
import '../unit_matcher.dart';
import 'decimal.dart';

/// Converts compact values such as `1.2K` or `3.4M`.
final class CompactCodec extends NumeralCodec<num> {
  /// Creates a compact number codec.
  CompactCodec({
    required this.unitSet,
    NumeralCodec<num>? style,
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
    this.compactOverflow = true,
  })  : style = style ??
            DecimalCodec(
              grouping: false,
              decimalSeparator: decimalSeparator,
              minFractionDigits: minFractionDigits,
              maxFractionDigits: maxFractionDigits,
              trimTrailingZeros: trimTrailingZeros,
              rounding: rounding,
            ),
        _unitMatcher = NumeralUnitMatcher(unitSet);

  /// Unit set used by this codec.
  final NumeralUnitSet unitSet;

  /// Whether rounded values can move to the next larger unit.
  final bool compactOverflow;

  /// Codec used for the numeric part before the compact unit.
  final NumeralCodec<num> style;

  final NumeralUnitMatcher _unitMatcher;

  @override
  String format(num value) {
    final special = formatSpecial(value);
    if (special != null) return special;

    var index = unitSet.indexFor(value.abs());
    if (compactOverflow) {
      index = _overflowIndex(value, index);
    }

    final unit = unitSet.units[index];
    return unit.format(style.format(value / unit.scale));
  }

  @override
  num parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw FormatException('Expected a compact number.', input);
    }

    final match = _unitMatcher.match(trimmed);
    final parsedNumber = style.parse(match.number);
    if (!parsedNumber.isFinite && match.number != trimmed) {
      throw FormatException(
        'Special compact values must not use units.',
        input,
      );
    }
    return normalizeNum(parsedNumber * match.unit.scale);
  }

  int _overflowIndex(num value, int index) {
    var selected = index;
    while (selected < unitSet.units.length - 1) {
      final current = unitSet.units[selected];
      final next = unitSet.units[selected + 1];
      final displayed = style.parse(
        style.format(value / current.scale),
      );
      final threshold = next.scale / current.scale;
      if (displayed.abs() < threshold) break;
      selected += 1;
    }
    return selected;
  }
}
