import 'decimal_codec.dart';
import 'internal.dart';
import 'numeral_codec.dart';
import 'rounding.dart';

/// A compact unit such as thousand, million, or billion.
final class CompactUnit {
  /// Creates a compact unit.
  const CompactUnit(
    this.scale,
    this.symbol, {
    this.aliases = const [],
  });

  /// Numeric scale represented by this unit.
  final num scale;

  /// Display symbol appended after the formatted number.
  final String symbol;

  /// Additional symbols accepted by parsers.
  final List<String> aliases;

  List<String> get _tokens => [
        if (symbol.isNotEmpty) symbol,
        ...aliases,
      ];
}

/// A set of compact units.
final class CompactUnitSet {
  /// Creates a compact unit set.
  const CompactUnitSet(this.units);

  /// Western short scale units: `K`, `M`, `B`, `T`, `P`.
  static const westernShort = CompactUnitSet([
    CompactUnit(1, ''),
    CompactUnit(1000, 'K', aliases: ['k', 'thousand']),
    CompactUnit(1000000, 'M', aliases: ['m', 'million']),
    CompactUnit(1000000000, 'B', aliases: ['b', 'billion']),
    CompactUnit(1000000000000, 'T', aliases: ['t', 'trillion']),
    CompactUnit(1000000000000000, 'P', aliases: ['p', 'quadrillion']),
  ]);

  /// Chinese-style units: `万`, `亿`, `兆`.
  static const chinese = CompactUnitSet([
    CompactUnit(1, ''),
    CompactUnit(10000, '万'),
    CompactUnit(100000000, '亿'),
    CompactUnit(1000000000000, '兆'),
  ]);

  /// Units ordered from smallest to largest.
  final List<CompactUnit> units;

  int indexFor(num magnitude) {
    var selected = 0;
    for (var index = 0; index < units.length; index += 1) {
      if (magnitude >= units[index].scale) selected = index;
    }
    return selected;
  }
}

/// Converts compact values such as `1.2K` or `3.4M`.
final class CompactCodec extends NumeralCodec<num> {
  /// Creates a compact number codec.
  CompactCodec({
    this.unitSet = CompactUnitSet.westernShort,
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
    this.compactOverflow = true,
  }) : _decimal = DecimalCodec(
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
  final CompactUnitSet unitSet;

  /// Whether rounded values can move to the next larger unit.
  final bool compactOverflow;

  final DecimalCodec _decimal;

  @override
  String format(num value) {
    final special = formatSpecial(value);
    if (special != null) return special;

    var index = unitSet.indexFor(value.abs());
    if (compactOverflow) {
      index = _overflowIndex(value, index);
    }

    final unit = unitSet.units[index];
    return '${_decimal.format(value / unit.scale)}${unit.symbol}';
  }

  @override
  num parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw FormatException('Expected a compact number.', input);
    }

    final match = _matchUnit(trimmed);
    final number = _decimal.parse(match.number);
    return normalizeNum(number * match.unit.scale);
  }

  int _overflowIndex(num value, int index) {
    var selected = index;
    while (selected < unitSet.units.length - 1) {
      final current = unitSet.units[selected];
      final next = unitSet.units[selected + 1];
      final displayed = _decimal.parse(_decimal.format(value / current.scale));
      final threshold = next.scale / current.scale;
      if (displayed.abs() < threshold) break;
      selected += 1;
    }
    return selected;
  }

  ({String number, CompactUnit unit}) _matchUnit(String input) {
    final lowerInput = input.toLowerCase();
    final candidates = <({CompactUnit unit, String token})>[
      for (final unit in unitSet.units)
        for (final token in unit._tokens) (unit: unit, token: token),
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
