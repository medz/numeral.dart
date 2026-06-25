import '../_utils.dart';
import '../codec.dart';
import '../rounding.dart';
import '../unit.dart';
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
  }) : style = style ??
            DecimalCodec(
              grouping: false,
              decimalSeparator: decimalSeparator,
              minFractionDigits: minFractionDigits,
              maxFractionDigits: maxFractionDigits,
              trimTrailingZeros: trimTrailingZeros,
              rounding: rounding,
            ) {
    if (unitSet.units.isEmpty) {
      throw ArgumentError.value(unitSet, 'unitSet', 'Must not be empty.');
    }
  }

  /// Unit set used by this codec.
  final NumeralUnitSet unitSet;

  /// Whether rounded values can move to the next larger unit.
  final bool compactOverflow;

  /// Codec used for the numeric part before the compact unit.
  final NumeralCodec<num> style;

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

    final match = _matchUnit(trimmed);
    final parsedNumber = style.parse(match.number);
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

  ({String number, NumeralUnit unit}) _matchUnit(String input) {
    final lowerInput = input.toLowerCase();
    final candidates = <({NumeralUnit unit, String token})>[
      for (final unit in unitSet.units)
        for (final token in unit.tokens) (unit: unit, token: token),
    ]..sort((a, b) => b.token.length.compareTo(a.token.length));

    for (final candidate in candidates) {
      final lowerToken = candidate.token.toLowerCase();
      if (!lowerInput.endsWith(lowerToken)) continue;

      final number = input.substring(0, input.length - candidate.token.length);
      if (number.trim().isEmpty) continue;
      return (number: number.trim(), unit: candidate.unit);
    }

    return (number: input, unit: unitSet.units.first);
  }
}
