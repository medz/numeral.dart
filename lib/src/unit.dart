/// Position of a unit symbol relative to the numeric value.
enum UnitPosition {
  /// The unit appears before the value.
  prefix,

  /// The unit appears after the value.
  suffix,
}

/// A numeric display unit such as `K`, `万`, or `KiB`.
final class NumeralUnit {
  /// Creates a numeric unit.
  const NumeralUnit(
    this.scale,
    this.symbol, {
    this.aliases = const [],
    this.position = UnitPosition.suffix,
    this.space = false,
  });

  /// Numeric scale represented by this unit.
  final num scale;

  /// Display symbol.
  final String symbol;

  /// Additional symbols accepted by parsers.
  final List<String> aliases;

  /// Position of [symbol] relative to the formatted value.
  final UnitPosition position;

  /// Whether a space is inserted between the value and [symbol].
  final bool space;

  /// Symbols accepted by parsers, ordered by callers before matching.
  List<String> get tokens => [
        if (symbol.isNotEmpty) symbol,
        ...aliases,
      ];

  /// Adds this unit's display symbol to [value].
  String format(String value, {bool? space}) {
    if (symbol.isEmpty) return value;

    final shouldSpace = space ?? this.space;
    final separator = shouldSpace ? ' ' : '';
    return switch (position) {
      UnitPosition.prefix => '$symbol$separator$value',
      UnitPosition.suffix => '$value$separator$symbol',
    };
  }
}

/// A set of numeric display units.
final class NumeralUnitSet {
  /// Creates a unit set.
  const NumeralUnitSet(this.units);

  /// Units ordered from smallest to largest.
  final List<NumeralUnit> units;

  /// Finds the largest unit whose scale is less than or equal to [magnitude].
  int indexFor(num magnitude) {
    if (units.isEmpty) {
      throw ArgumentError.value(this, 'unitSet', 'Must not be empty.');
    }

    var selected = 0;
    for (var index = 0; index < units.length; index += 1) {
      if (magnitude >= units[index].scale) selected = index;
    }
    return selected;
  }
}
