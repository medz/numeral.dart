import 'dart:math' as math;

/// Rounding behavior used by numeric formatters.
enum Rounding {
  /// Round to the nearest representable fraction digit.
  halfUp,

  /// Drop extra fraction digits without rounding.
  truncate,
}

/// A formatter that can render numeric values and parse strings back to a
/// numeric representation.
abstract interface class NumeralFormatter<T extends num> {
  /// Formats [value] into a display string.
  String format(num value);

  /// Parses [input] and returns the numeric value.
  ///
  /// Throws [FormatException] when [input] cannot be parsed by this formatter.
  T parse(String input);

  /// Parses [input], returning `null` instead of throwing [FormatException].
  T? tryParse(String input);
}

/// Creates a formatter for ordinary decimal numbers.
DecimalFormatter decimal({
  bool grouping = true,
  String groupSeparator = ',',
  String decimalSeparator = '.',
  int minFractionDigits = 0,
  int maxFractionDigits = 3,
  bool trimTrailingZeros = true,
  Rounding rounding = Rounding.halfUp,
}) {
  return DecimalFormatter(
    grouping: grouping,
    groupSeparator: groupSeparator,
    decimalSeparator: decimalSeparator,
    minFractionDigits: minFractionDigits,
    maxFractionDigits: maxFractionDigits,
    trimTrailingZeros: trimTrailingZeros,
    rounding: rounding,
  );
}

/// Creates a formatter for compact values such as `1.2K` or `3.4M`.
CompactFormatter compact({
  CompactUnitSet unitSet = CompactUnitSet.westernShort,
  String decimalSeparator = '.',
  int minFractionDigits = 0,
  int maxFractionDigits = 2,
  bool trimTrailingZeros = true,
  Rounding rounding = Rounding.halfUp,
  bool compactOverflow = true,
}) {
  return CompactFormatter(
    unitSet: unitSet,
    decimalSeparator: decimalSeparator,
    minFractionDigits: minFractionDigits,
    maxFractionDigits: maxFractionDigits,
    trimTrailingZeros: trimTrailingZeros,
    rounding: rounding,
    compactOverflow: compactOverflow,
  );
}

/// Creates a formatter for percentage values.
PercentFormatter percent({
  String symbol = '%',
  num scale = 100,
  bool spaceBeforeSymbol = false,
  bool requireSymbol = true,
  String decimalSeparator = '.',
  int minFractionDigits = 0,
  int maxFractionDigits = 2,
  bool trimTrailingZeros = true,
  Rounding rounding = Rounding.halfUp,
}) {
  return PercentFormatter(
    symbol: symbol,
    scale: scale,
    spaceBeforeSymbol: spaceBeforeSymbol,
    requireSymbol: requireSymbol,
    decimalSeparator: decimalSeparator,
    minFractionDigits: minFractionDigits,
    maxFractionDigits: maxFractionDigits,
    trimTrailingZeros: trimTrailingZeros,
    rounding: rounding,
  );
}

/// Creates a formatter for byte counts.
BytesFormatter bytes({
  bool binary = false,
  bool spaceBeforeUnit = true,
  String decimalSeparator = '.',
  int minFractionDigits = 0,
  int maxFractionDigits = 2,
  bool trimTrailingZeros = true,
  Rounding rounding = Rounding.halfUp,
}) {
  return BytesFormatter(
    unitSet: binary ? ByteUnitSet.binary : ByteUnitSet.decimal,
    spaceBeforeUnit: spaceBeforeUnit,
    decimalSeparator: decimalSeparator,
    minFractionDigits: minFractionDigits,
    maxFractionDigits: maxFractionDigits,
    trimTrailingZeros: trimTrailingZeros,
    rounding: rounding,
  );
}

/// Creates a formatter for display-oriented currency values.
CurrencyFormatter currency(
  String symbol, {
  bool symbolOnRight = false,
  bool spaceBetweenSymbolAndNumber = false,
  bool grouping = true,
  String groupSeparator = ',',
  String decimalSeparator = '.',
  int minFractionDigits = 2,
  int maxFractionDigits = 2,
  bool trimTrailingZeros = false,
  Rounding rounding = Rounding.halfUp,
}) {
  return CurrencyFormatter(
    symbol: symbol,
    symbolOnRight: symbolOnRight,
    spaceBetweenSymbolAndNumber: spaceBetweenSymbolAndNumber,
    grouping: grouping,
    groupSeparator: groupSeparator,
    decimalSeparator: decimalSeparator,
    minFractionDigits: minFractionDigits,
    maxFractionDigits: maxFractionDigits,
    trimTrailingZeros: trimTrailingZeros,
    rounding: rounding,
  );
}

/// Formats ordinary decimal numbers.
final class DecimalFormatter implements NumeralFormatter<num> {
  /// Creates a formatter for ordinary decimal numbers.
  DecimalFormatter({
    this.grouping = true,
    this.groupSeparator = ',',
    this.decimalSeparator = '.',
    this.minFractionDigits = 0,
    this.maxFractionDigits = 3,
    this.trimTrailingZeros = true,
    this.rounding = Rounding.halfUp,
  }) {
    _checkFractionDigits(minFractionDigits, maxFractionDigits);
    _checkSeparator(decimalSeparator, 'decimalSeparator');
    if (grouping) _checkSeparator(groupSeparator, 'groupSeparator');
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

  @override
  String format(num value) {
    final special = _formatSpecial(value);
    if (special != null) return special;

    final fixed = _fixed(value, maxFractionDigits, rounding);
    final parts = fixed.split('.');
    final integer = grouping ? _groupInteger(parts.first) : parts.first;
    final fraction = parts.length == 1
        ? ''
        : _normalizeFraction(
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

  @override
  num? tryParse(String input) {
    try {
      return parse(input);
    } on FormatException {
      return null;
    }
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
      normalized = normalized.replaceAll(groupSeparator, '');
    }
    if (decimalSeparator != '.') {
      normalized = normalized.replaceAll(decimalSeparator, '.');
    }

    final valid = RegExp(
      r'^[+-]?(?:(?:\d+(?:\.\d*)?)|(?:\.\d+)|Infinity|NaN)(?:[eE][+-]?\d+)?$',
    ).hasMatch(normalized);

    if (!valid) {
      throw FormatException('Expected a number.', input);
    }

    return normalized;
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

  int _indexFor(num magnitude) {
    var selected = 0;
    for (var index = 0; index < units.length; index += 1) {
      if (magnitude >= units[index].scale) selected = index;
    }
    return selected;
  }
}

/// Formats compact values such as `1.2K` or `3.4M`.
final class CompactFormatter implements NumeralFormatter<num> {
  /// Creates a compact number formatter.
  CompactFormatter({
    this.unitSet = CompactUnitSet.westernShort,
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
    this.compactOverflow = true,
  }) : _decimal = DecimalFormatter(
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

  /// Unit set used by this formatter.
  final CompactUnitSet unitSet;

  /// Whether rounded values can move to the next larger unit.
  final bool compactOverflow;

  final DecimalFormatter _decimal;

  @override
  String format(num value) {
    final special = _formatSpecial(value);
    if (special != null) return special;

    var index = unitSet._indexFor(value.abs());
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
    return _normalizeNum(number * match.unit.scale);
  }

  @override
  num? tryParse(String input) {
    try {
      return parse(input);
    } on FormatException {
      return null;
    }
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

/// Formats percentage values.
final class PercentFormatter implements NumeralFormatter<double> {
  /// Creates a percentage formatter.
  PercentFormatter({
    this.symbol = '%',
    this.scale = 100,
    this.spaceBeforeSymbol = false,
    this.requireSymbol = true,
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
  }) : _decimal = DecimalFormatter(
          grouping: false,
          decimalSeparator: decimalSeparator,
          minFractionDigits: minFractionDigits,
          maxFractionDigits: maxFractionDigits,
          trimTrailingZeros: trimTrailingZeros,
          rounding: rounding,
        ) {
    if (scale == 0) {
      throw ArgumentError.value(scale, 'scale', 'Must not be zero.');
    }
    _checkSeparator(symbol, 'symbol');
  }

  /// Symbol appended after the formatted number.
  final String symbol;

  /// Multiplier applied when formatting and parsing.
  final num scale;

  /// Whether a space is inserted before [symbol].
  final bool spaceBeforeSymbol;

  /// Whether parsing requires [symbol].
  final bool requireSymbol;

  final DecimalFormatter _decimal;

  @override
  String format(num value) {
    final special = _formatSpecial(value);
    if (special != null) return special;

    final space = spaceBeforeSymbol ? ' ' : '';
    return '${_decimal.format(value * scale)}$space$symbol';
  }

  @override
  double parse(String input) {
    final number = _stripSuffix(input, symbol, require: requireSymbol);
    return _decimal.parse(number) / scale;
  }

  @override
  double? tryParse(String input) {
    try {
      return parse(input);
    } on FormatException {
      return null;
    }
  }
}

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

  int _indexFor(num magnitude) {
    var selected = 0;
    for (var index = 0; index < units.length; index += 1) {
      if (magnitude >= units[index].scale) selected = index;
    }
    return selected;
  }
}

/// Formats byte counts.
final class BytesFormatter implements NumeralFormatter<int> {
  /// Creates a byte formatter.
  BytesFormatter({
    this.unitSet = ByteUnitSet.decimal,
    this.spaceBeforeUnit = true,
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
  }) : _decimal = DecimalFormatter(
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

  /// Byte unit set used by this formatter.
  final ByteUnitSet unitSet;

  /// Whether a space is inserted before the unit symbol.
  final bool spaceBeforeUnit;

  final DecimalFormatter _decimal;

  @override
  String format(num value) {
    final special = _formatSpecial(value);
    if (special != null) return special;

    final unit = unitSet.units[unitSet._indexFor(value.abs())];
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

  @override
  int? tryParse(String input) {
    try {
      return parse(input);
    } on FormatException {
      return null;
    }
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

/// Formats display-oriented currency values.
final class CurrencyFormatter implements NumeralFormatter<num> {
  /// Creates a currency formatter.
  CurrencyFormatter({
    required this.symbol,
    this.symbolOnRight = false,
    this.spaceBetweenSymbolAndNumber = false,
    bool grouping = true,
    String groupSeparator = ',',
    String decimalSeparator = '.',
    int minFractionDigits = 2,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = false,
    Rounding rounding = Rounding.halfUp,
  }) : _decimal = DecimalFormatter(
          grouping: grouping,
          groupSeparator: groupSeparator,
          decimalSeparator: decimalSeparator,
          minFractionDigits: minFractionDigits,
          maxFractionDigits: maxFractionDigits,
          trimTrailingZeros: trimTrailingZeros,
          rounding: rounding,
        ) {
    _checkSeparator(symbol, 'symbol');
  }

  /// Currency symbol.
  final String symbol;

  /// Whether [symbol] appears after the number.
  final bool symbolOnRight;

  /// Whether a space is inserted between symbol and number.
  final bool spaceBetweenSymbolAndNumber;

  final DecimalFormatter _decimal;

  @override
  String format(num value) {
    final special = _formatSpecial(value);
    if (special != null) {
      final space = spaceBetweenSymbolAndNumber ? ' ' : '';
      return symbolOnRight ? '$special$space$symbol' : '$symbol$space$special';
    }

    final isNegative = value.isNegative;
    final number = _decimal.format(value.abs());
    final space = spaceBetweenSymbolAndNumber ? ' ' : '';
    final formatted =
        symbolOnRight ? '$number$space$symbol' : '$symbol$space$number';
    return isNegative ? '-$formatted' : formatted;
  }

  @override
  num parse(String input) {
    var trimmed = input.trim();
    final isNegative = trimmed.startsWith('-');
    if (isNegative) {
      trimmed = trimmed.substring(1).trim();
    }
    late final String number;

    if (symbolOnRight) {
      number = _stripSuffix(trimmed, symbol, require: true);
    } else if (trimmed.startsWith(symbol)) {
      number = trimmed.substring(symbol.length).trim();
    } else {
      throw FormatException('Expected currency symbol "$symbol".', input);
    }

    final parsed = _decimal.parse(number);
    return isNegative ? -parsed : parsed;
  }

  @override
  num? tryParse(String input) {
    try {
      return parse(input);
    } on FormatException {
      return null;
    }
  }
}

String _fixed(num value, int fractionDigits, Rounding rounding) {
  if (rounding == Rounding.halfUp) {
    return value.toStringAsFixed(fractionDigits);
  }

  if (fractionDigits == 0) {
    return value.truncate().toString();
  }

  final factor = math.pow(10, fractionDigits);
  final scaled = value * factor;
  final truncated = value.isNegative ? scaled.ceil() : scaled.floor();
  return (truncated / factor).toStringAsFixed(fractionDigits);
}

String _normalizeFraction(
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

String? _formatSpecial(num value) {
  if (value.isNaN) return 'NaN';
  if (value == double.infinity) return '∞';
  if (value == double.negativeInfinity) return '-∞';
  return null;
}

num _normalizeNum(num value) {
  if (!value.isFinite) return value;
  final integer = value.round();
  if ((value - integer).abs() <= 1e-9) return integer;
  return value;
}

String _stripSuffix(String input, String suffix, {required bool require}) {
  final trimmed = input.trim();
  if (!trimmed.endsWith(suffix)) {
    if (!require) return trimmed;
    throw FormatException('Expected suffix "$suffix".', input);
  }
  return trimmed.substring(0, trimmed.length - suffix.length).trim();
}

void _checkFractionDigits(int minFractionDigits, int maxFractionDigits) {
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
  if (minFractionDigits > maxFractionDigits) {
    throw ArgumentError.value(
      minFractionDigits,
      'minFractionDigits',
      'Must not be greater than maxFractionDigits.',
    );
  }
}

void _checkSeparator(String value, String name) {
  if (value.isEmpty) {
    throw ArgumentError.value(value, name, 'Must not be empty.');
  }
}
