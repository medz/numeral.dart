import 'unit.dart';

/// Matches numeric display units from formatted strings.
final class NumeralUnitMatcher {
  /// Creates a matcher for [unitSet].
  NumeralUnitMatcher(NumeralUnitSet unitSet) : this._(_checkUnits(unitSet));

  NumeralUnitMatcher._(List<NumeralUnit> units)
      : _units = units,
        _fallback = units.first,
        _tokens = _tokensFor(units);

  final List<NumeralUnit> _units;
  final NumeralUnit _fallback;
  final List<({NumeralUnit unit, String token, String lowerToken})> _tokens;

  /// Number of units in this matcher.
  int get length => _units.length;

  /// Returns the unit at [index].
  NumeralUnit unitAt(int index) => _units[index];

  /// Finds the largest unit whose scale is less than or equal to [magnitude].
  int indexFor(num magnitude) {
    var lower = 0;
    var upper = _units.length;

    while (lower < upper) {
      final middle = lower + ((upper - lower) >> 1);
      if (magnitude >= _units[middle].scale) {
        lower = middle + 1;
      } else {
        upper = middle;
      }
    }

    return lower == 0 ? 0 : lower - 1;
  }

  /// Finds the largest unit whose scale is less than or equal to [magnitude].
  NumeralUnit unitFor(num magnitude) => _units[indexFor(magnitude)];

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
    final units = unitSet.units;
    if (units.isEmpty) {
      throw ArgumentError.value(unitSet, 'unitSet', 'Must not be empty.');
    }

    num previousScale = 0;
    final tokenOwners = <String, NumeralUnit>{};
    for (final unit in units) {
      final scale = unit.scale;
      if (!scale.isFinite || scale <= 0) {
        throw ArgumentError.value(
          scale,
          'unitSet',
          'Unit scales must be finite and positive.',
        );
      }
      if (scale <= previousScale) {
        throw ArgumentError.value(
          unitSet,
          'unitSet',
          'Unit scales must be strictly ascending.',
        );
      }
      previousScale = scale;

      for (final token in unit.tokens) {
        if (token.isEmpty) continue;
        if (token.trim().isEmpty) {
          throw ArgumentError.value(
            token,
            'unitSet',
            'Unit tokens must not be blank.',
          );
        }

        final lowerToken = token.toLowerCase();
        final existing = tokenOwners[lowerToken];
        if (existing != null && !identical(existing, unit)) {
          throw ArgumentError.value(
            token,
            'unitSet',
            'Unit tokens must be unique case-insensitively.',
          );
        }
        tokenOwners[lowerToken] = unit;
      }
    }

    return List.unmodifiable(units);
  }

  static List<({NumeralUnit unit, String token, String lowerToken})> _tokensFor(
    List<NumeralUnit> units,
  ) {
    final seenTokens = <String>{};
    final tokens = <({NumeralUnit unit, String token, String lowerToken})>[];
    for (final unit in units) {
      for (final token in unit.tokens) {
        if (token.isEmpty) continue;

        final lowerToken = token.toLowerCase();
        if (!seenTokens.add(lowerToken)) continue;
        tokens.add((unit: unit, token: token, lowerToken: lowerToken));
      }
    }

    tokens.sort((a, b) => b.token.length.compareTo(a.token.length));
    return tokens;
  }
}
