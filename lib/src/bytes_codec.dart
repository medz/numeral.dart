import 'decimal_codec.dart';
import 'internal.dart';
import 'numeral_codec.dart';
import 'rounding.dart';

/// A byte unit such as KB or MiB.
final class ByteUnit {
  /// Creates a byte unit.
  const ByteUnit(
    this.scale,
    this.symbol, {
    this.aliases = const [],
  });

  /// Number of bytes represented by one unit.
  final int scale;

  /// Display symbol.
  final String symbol;

  /// Additional symbols accepted by parsers.
  final List<String> aliases;

  List<String> get _tokens => [
        symbol,
        ...aliases,
      ];
}

/// A byte unit set.
final class ByteUnitSet {
  /// Creates a byte unit set.
  const ByteUnitSet(this.units);

  /// Decimal byte units using powers of 1000.
  static const decimal = ByteUnitSet([
    ByteUnit(1, 'B', aliases: ['byte', 'bytes']),
    ByteUnit(1000, 'KB', aliases: ['kb', 'kilobyte', 'kilobytes']),
    ByteUnit(1000000, 'MB', aliases: ['mb', 'megabyte', 'megabytes']),
    ByteUnit(1000000000, 'GB', aliases: ['gb', 'gigabyte', 'gigabytes']),
    ByteUnit(1000000000000, 'TB', aliases: ['tb', 'terabyte', 'terabytes']),
    ByteUnit(1000000000000000, 'PB', aliases: ['pb', 'petabyte', 'petabytes']),
  ]);

  /// Binary byte units using powers of 1024.
  static const binary = ByteUnitSet([
    ByteUnit(1, 'B', aliases: ['byte', 'bytes']),
    ByteUnit(1024, 'KiB', aliases: ['kib', 'kibibyte', 'kibibytes']),
    ByteUnit(1048576, 'MiB', aliases: ['mib', 'mebibyte', 'mebibytes']),
    ByteUnit(1073741824, 'GiB', aliases: ['gib', 'gibibyte', 'gibibytes']),
    ByteUnit(1099511627776, 'TiB', aliases: ['tib', 'tebibyte', 'tebibytes']),
    ByteUnit(
      1125899906842624,
      'PiB',
      aliases: ['pib', 'pebibyte', 'pebibytes'],
    ),
  ]);

  /// Units ordered from smallest to largest.
  final List<ByteUnit> units;

  int indexFor(num magnitude) {
    var selected = 0;
    for (var index = 0; index < units.length; index += 1) {
      if (magnitude >= units[index].scale) selected = index;
    }
    return selected;
  }
}

/// Converts byte counts to and from byte size strings.
final class BytesCodec extends NumeralCodec<int> {
  /// Creates a decimal byte codec using powers of 1000.
  BytesCodec({
    this.unitSet = ByteUnitSet.decimal,
    this.spaceBeforeUnit = true,
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
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

  /// Creates a binary byte codec using powers of 1024.
  BytesCodec.binary({
    bool spaceBeforeUnit = true,
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
  }) : this(
          unitSet: ByteUnitSet.binary,
          spaceBeforeUnit: spaceBeforeUnit,
          decimalSeparator: decimalSeparator,
          minFractionDigits: minFractionDigits,
          maxFractionDigits: maxFractionDigits,
          trimTrailingZeros: trimTrailingZeros,
          rounding: rounding,
        );

  /// Byte unit set used by this codec.
  final ByteUnitSet unitSet;

  /// Whether a space is inserted before the unit symbol.
  final bool spaceBeforeUnit;

  final DecimalCodec _decimal;

  @override
  String format(num value) {
    final special = formatSpecial(value);
    if (special != null) return special;

    final unit = unitSet.units[unitSet.indexFor(value.abs())];
    final space = spaceBeforeUnit ? ' ' : '';
    return '${_decimal.format(value / unit.scale)}$space${unit.symbol}';
  }

  @override
  int parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw FormatException('Expected a byte size.', input);
    }

    final match = _matchUnit(trimmed);
    final value = _decimal.parse(match.number) * match.unit.scale;
    final rounded = value.round();
    if ((value - rounded).abs() > 1e-9) {
      throw FormatException('Byte sizes must resolve to a whole byte.', input);
    }
    return rounded;
  }

  ({String number, ByteUnit unit}) _matchUnit(String input) {
    final lowerInput = input.toLowerCase();
    final candidates = <({ByteUnit unit, String token})>[
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
