import 'unit.dart';

/// Matches numeric display units from formatted strings.
final class NumeralUnitMatcher {
  /// Creates a matcher for [unitSet].
  NumeralUnitMatcher(NumeralUnitSet unitSet)
      : _fallback = _checkUnits(unitSet).first,
        _tokens = [
          for (final unit in unitSet.units)
            for (final token in unit.tokens)
              if (token.isNotEmpty)
                (
                  unit: unit,
                  token: token,
                  lowerToken: token.toLowerCase(),
                ),
        ]..sort((a, b) => b.token.length.compareTo(a.token.length));

  final NumeralUnit _fallback;
  final List<({NumeralUnit unit, String token, String lowerToken})> _tokens;

  /// Matches the longest known unit token in [input].
  ({String number, NumeralUnit unit}) match(String input) {
    final lowerInput = input.toLowerCase();

    for (final candidate in _tokens) {
      final number = switch (candidate.unit.position) {
        UnitPosition.prefix => _matchPrefix(input, lowerInput, candidate),
        UnitPosition.suffix => _matchSuffix(input, lowerInput, candidate),
      };
      if (number == null) continue;
      if (number.trim().isEmpty) continue;
      return (number: number.trim(), unit: candidate.unit);
    }

    return (number: input, unit: _fallback);
  }

  String? _matchPrefix(
    String input,
    String lowerInput,
    ({NumeralUnit unit, String token, String lowerToken}) candidate,
  ) {
    if (!lowerInput.startsWith(candidate.lowerToken)) return null;
    return input.substring(candidate.token.length);
  }

  String? _matchSuffix(
    String input,
    String lowerInput,
    ({NumeralUnit unit, String token, String lowerToken}) candidate,
  ) {
    if (!lowerInput.endsWith(candidate.lowerToken)) return null;
    return input.substring(0, input.length - candidate.token.length);
  }

  static List<NumeralUnit> _checkUnits(NumeralUnitSet unitSet) {
    if (unitSet.units.isEmpty) {
      throw ArgumentError.value(unitSet, 'unitSet', 'Must not be empty.');
    }
    return unitSet.units;
  }
}
