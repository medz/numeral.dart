import '../codec.dart';
import '../rounding.dart';
import '../unit.dart';
import '../unit_matcher.dart';
import 'decimal.dart';

/// Decimal byte units using powers of 1000.
const decimalByteUnits = NumeralUnitSet([
  NumeralUnit(1, 'B', aliases: ['byte', 'bytes'], space: true),
  NumeralUnit(
    1000,
    'KB',
    aliases: ['kb', 'kilobyte', 'kilobytes'],
    space: true,
  ),
  NumeralUnit(
    1000000,
    'MB',
    aliases: ['mb', 'megabyte', 'megabytes'],
    space: true,
  ),
  NumeralUnit(
    1000000000,
    'GB',
    aliases: ['gb', 'gigabyte', 'gigabytes'],
    space: true,
  ),
  NumeralUnit(
    1000000000000,
    'TB',
    aliases: ['tb', 'terabyte', 'terabytes'],
    space: true,
  ),
  NumeralUnit(
    1000000000000000,
    'PB',
    aliases: ['pb', 'petabyte', 'petabytes'],
    space: true,
  ),
]);

/// Binary byte units using powers of 1024.
const binaryByteUnits = NumeralUnitSet([
  NumeralUnit(1, 'B', aliases: ['byte', 'bytes'], space: true),
  NumeralUnit(
    1024,
    'KiB',
    aliases: ['kib', 'kibibyte', 'kibibytes'],
    space: true,
  ),
  NumeralUnit(
    1048576,
    'MiB',
    aliases: ['mib', 'mebibyte', 'mebibytes'],
    space: true,
  ),
  NumeralUnit(
    1073741824,
    'GiB',
    aliases: ['gib', 'gibibyte', 'gibibytes'],
    space: true,
  ),
  NumeralUnit(
    1099511627776,
    'TiB',
    aliases: ['tib', 'tebibyte', 'tebibytes'],
    space: true,
  ),
  NumeralUnit(
    1125899906842624,
    'PiB',
    aliases: ['pib', 'pebibyte', 'pebibytes'],
    space: true,
  ),
]);

/// Converts byte counts to and from byte size strings.
final class BytesCodec extends NumeralCodec<int> {
  /// Creates a decimal byte codec using powers of 1000.
  BytesCodec({
    this.unitSet = decimalByteUnits,
    this.spaceBeforeUnit,
    NumeralCodec<num>? style,
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
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

  /// Creates a binary byte codec using powers of 1024.
  BytesCodec.binary({
    bool spaceBeforeUnit = true,
    NumeralCodec<num>? style,
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
  }) : this(
          unitSet: binaryByteUnits,
          spaceBeforeUnit: spaceBeforeUnit,
          style: style,
          decimalSeparator: decimalSeparator,
          minFractionDigits: minFractionDigits,
          maxFractionDigits: maxFractionDigits,
          trimTrailingZeros: trimTrailingZeros,
          rounding: rounding,
        );

  /// Byte unit set used by this codec.
  final NumeralUnitSet unitSet;

  /// Whether a space is inserted before the unit symbol.
  final bool? spaceBeforeUnit;

  /// Codec used for the numeric part before the byte unit.
  final NumeralCodec<num> style;

  final NumeralUnitMatcher _unitMatcher;

  @override
  String format(num value) {
    if (!value.isFinite || value % 1 != 0) {
      throw ArgumentError.value(
        value,
        'value',
        'Must be a finite whole byte count.',
      );
    }

    final unit = _unitMatcher.unitFor(value.abs());
    return unit.format(
      style.format(value / unit.scale),
      space: spaceBeforeUnit,
    );
  }

  @override
  int parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw FormatException('Expected a byte size.', input);
    }

    final match = _unitMatcher.match(trimmed);
    final value = style.parse(match.number) * match.unit.scale;
    if (!value.isFinite) {
      throw FormatException(
        'Byte sizes must resolve to a finite whole byte.',
        input,
      );
    }

    final rounded = value.round();
    if ((value - rounded).abs() > 1e-9) {
      throw FormatException('Byte sizes must resolve to a whole byte.', input);
    }
    return rounded;
  }
}
