import 'unit.dart';

/// Matches numeric display units from the end of formatted strings.
final class NumeralUnitMatcher {
  /// Creates a matcher for [unitSet].
  NumeralUnitMatcher(NumeralUnitSet unitSet)
      : _fallback = _checkUnits(unitSet).first,
        _tokens = [
          for (final unit in unitSet.units)
            for (final token in unit.tokens)
              (
                unit: unit,
                token: token,
                lowerToken: token.toLowerCase(),
              ),
        ]..sort((a, b) => b.token.length.compareTo(a.token.length));

  final NumeralUnit _fallback;
  final List<({NumeralUnit unit, String token, String lowerToken})> _tokens;

  /// Matches the longest known unit suffix in [input].
  ({String number, NumeralUnit unit}) match(String input) {
    final lowerInput = input.toLowerCase();

    for (final candidate in _tokens) {
      if (!lowerInput.endsWith(candidate.lowerToken)) continue;

      final number = input.substring(0, input.length - candidate.token.length);
      if (number.trim().isEmpty) continue;
      return (number: number.trim(), unit: candidate.unit);
    }

    return (number: input, unit: _fallback);
  }

  static List<NumeralUnit> _checkUnits(NumeralUnitSet unitSet) {
    if (unitSet.units.isEmpty) {
      throw ArgumentError.value(unitSet, 'unitSet', 'Must not be empty.');
    }
    return unitSet.units;
  }
}
