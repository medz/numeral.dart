/// Japanese numerals language pack.
library;

import 'src/codec.dart';
import 'src/codec/compact.dart';
import 'src/language.dart';
import 'src/rounding.dart';
import 'src/unit.dart';

int _checkedInteger(num value, String message) {
  if (!value.isFinite || value % 1 != 0) {
    throw ArgumentError.value(value, 'value', message);
  }

  final integer = value.toInt();
  if (value is double && integer.toDouble() != value) {
    throw ArgumentError.value(
      value,
      'value',
      'Must be exactly representable as an integer.',
    );
  }
  return integer;
}

/// Japanese numerals language pack.
const ja = JapaneseNumerals();

/// Japanese compact units: `万`, `億`, `兆`.
const japaneseCompactUnits = NumeralUnitSet([
  NumeralUnit(1, ''),
  NumeralUnit(10000, '万', aliases: ['萬']),
  NumeralUnit(100000000, '億'),
  NumeralUnit(1000000000000, '兆'),
]);

/// Creates a Japanese compact number codec.
CompactCodec compact({
  String decimalSeparator = '.',
  int minFractionDigits = 0,
  int maxFractionDigits = 2,
  bool trimTrailingZeros = true,
  Rounding rounding = Rounding.halfUp,
  bool compactOverflow = true,
}) {
  return ja.compact(
    decimalSeparator: decimalSeparator,
    minFractionDigits: minFractionDigits,
    maxFractionDigits: maxFractionDigits,
    trimTrailingZeros: trimTrailingZeros,
    rounding: rounding,
    compactOverflow: compactOverflow,
  );
}

/// Creates a Japanese cardinal number codec.
JapaneseCardinalCodec cardinal() => ja.cardinal();

/// Creates a Japanese year number codec.
JapaneseYearCodec year({String suffix = ''}) => ja.year(suffix: suffix);

/// Japanese numerals language pack.
final class JapaneseNumerals implements NumeralLanguage {
  /// Creates a Japanese numerals language pack.
  const JapaneseNumerals();

  @override
  String get locale => 'ja';

  @override
  NumeralUnitSet get compactUnits => japaneseCompactUnits;

  @override
  CompactCodec compact({
    String decimalSeparator = '.',
    int minFractionDigits = 0,
    int maxFractionDigits = 2,
    bool trimTrailingZeros = true,
    Rounding rounding = Rounding.halfUp,
    bool compactOverflow = true,
  }) {
    return CompactCodec(
      unitSet: compactUnits,
      decimalSeparator: decimalSeparator,
      minFractionDigits: minFractionDigits,
      maxFractionDigits: maxFractionDigits,
      trimTrailingZeros: trimTrailingZeros,
      rounding: rounding,
      compactOverflow: compactOverflow,
    );
  }

  /// Creates a Japanese cardinal number codec.
  JapaneseCardinalCodec cardinal() => const JapaneseCardinalCodec();

  /// Creates a Japanese year number codec.
  JapaneseYearCodec year({String suffix = ''}) => JapaneseYearCodec(
        suffix: suffix,
      );
}

/// Converts years to and from Japanese digit-by-digit numerals.
final class JapaneseYearCodec extends NumeralCodec<int> {
  /// Creates a Japanese year number codec.
  const JapaneseYearCodec({this.suffix = ''});

  /// Text appended after the formatted year, such as `年`.
  final String suffix;

  static const _digits = ['〇', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
  static const _digitValues = {
    '〇': 0,
    '零': 0,
    '一': 1,
    '二': 2,
    '三': 3,
    '四': 4,
    '五': 5,
    '六': 6,
    '七': 7,
    '八': 8,
    '九': 9,
  };

  @override
  String format(num value) {
    final integer = _checkedInteger(
      value,
      'Must be a non-negative finite integer.',
    );
    if (integer < 0) {
      throw ArgumentError.value(
        value,
        'value',
        'Must be a non-negative finite integer.',
      );
    }

    final buffer = StringBuffer();
    for (final codeUnit in integer.toString().codeUnits) {
      buffer.write(_digits[codeUnit - 48]);
    }
    buffer.write(suffix);
    return buffer.toString();
  }

  @override
  int parse(String input) {
    var text = input.trim();
    if (suffix.isNotEmpty) {
      if (!text.endsWith(suffix)) {
        throw FormatException('Expected year suffix "$suffix".', input);
      }
      text = text.substring(0, text.length - suffix.length);
    } else if (text.endsWith('年')) {
      text = text.substring(0, text.length - 1);
    }

    if (text.isEmpty) {
      throw FormatException('Expected a Japanese year number.', input);
    }

    final buffer = StringBuffer();
    for (final char in text.runes.map(String.fromCharCode)) {
      final value = _digitValues[char];
      if (value == null) {
        throw FormatException('Unexpected Japanese year token.', input);
      }
      buffer.write(value);
    }

    return int.parse(buffer.toString());
  }
}

/// Converts integers to and from Japanese cardinal numerals.
///
/// Formatting emits normalized kanji numerals and omits implied zeros, such as
/// `百一` for 101 and `一万一` for 10001. Parsing accepts common zero markers
/// and formal digit variants while preserving the same additive semantics.
final class JapaneseCardinalCodec extends NumeralCodec<int> {
  /// Creates a Japanese cardinal codec.
  const JapaneseCardinalCodec();

  static const _digits = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
  static const _smallUnits = ['', '十', '百', '千'];
  static const _sectionUnits = ['', '万', '億', '兆', '京'];
  static const _smallScales = [1, 10, 100, 1000];
  static const _sectionUnitValues = {
    '万': 10000,
    '萬': 10000,
    '億': 100000000,
    '兆': 1000000000000,
    '京': 10000000000000000,
  };
  static const _digitValues = {
    '零': 0,
    '〇': 0,
    '一': 1,
    '壱': 1,
    '壹': 1,
    '二': 2,
    '弐': 2,
    '貳': 2,
    '三': 3,
    '参': 3,
    '參': 3,
    '四': 4,
    '肆': 4,
    '五': 5,
    '伍': 5,
    '六': 6,
    '陸': 6,
    '七': 7,
    '漆': 7,
    '柒': 7,
    '八': 8,
    '捌': 8,
    '九': 9,
    '玖': 9,
  };
  static const _smallUnitValues = {
    '十': 10,
    '拾': 10,
    '百': 100,
    '佰': 100,
    '千': 1000,
    '仟': 1000,
  };

  @override
  String format(num value) {
    final integer = _checkedInteger(value, 'Must be a finite integer.');
    if (integer == 0) return _digits[0];
    if (integer < 0) return '負${format(-integer)}';

    final sections = <int>[];
    var rest = integer;
    while (rest > 0) {
      sections.add(rest % 10000);
      rest ~/= 10000;
    }
    if (sections.length > _sectionUnits.length) {
      throw ArgumentError.value(
        value,
        'value',
        'Exceeds supported Japanese section units.',
      );
    }

    final buffer = StringBuffer();
    for (var index = sections.length - 1; index >= 0; index -= 1) {
      final section = sections[index];
      if (section == 0) continue;

      buffer
        ..write(
          _formatSection(
            section,
            beforeSectionUnit: index > 0,
          ),
        )
        ..write(_sectionUnits[index]);
    }

    return buffer.toString();
  }

  @override
  int parse(String input) {
    var text = input.trim();
    if (text.isEmpty) {
      throw FormatException('Expected a Japanese cardinal number.', input);
    }

    final negative = text.startsWith('負');
    if (negative) {
      text = text.substring(1);
      if (text.isEmpty) {
        throw FormatException('Expected a Japanese cardinal number.', input);
      }
    }

    if (text.runes.length == 1 &&
        _digitValues[String.fromCharCode(text.runes.single)] == 0) {
      return 0;
    }

    var total = 0;
    var sectionText = StringBuffer();
    var lastSectionUnit = 1000000000000000000;
    for (final char in text.runes.map(String.fromCharCode)) {
      final sectionUnit = _sectionUnitValues[char];
      if (sectionUnit == null) {
        sectionText.write(char);
        continue;
      }

      if (sectionUnit >= lastSectionUnit) {
        throw FormatException('Unexpected Japanese cardinal token.', input);
      }

      final rawSection = sectionText.toString();
      if (rawSection.isEmpty && total > 0) {
        throw FormatException('Unexpected Japanese cardinal token.', input);
      }

      final section = _parseSection(
        rawSection,
        input,
        allowEmptyAsOne: true,
        allowLeadingZero: false,
      );
      if (section == 0) {
        throw FormatException('Unexpected Japanese cardinal token.', input);
      }

      total += section * sectionUnit;
      sectionText = StringBuffer();
      lastSectionUnit = sectionUnit;
    }

    final lowerSection = _parseSection(
      sectionText.toString(),
      input,
      allowEmptyAsOne: false,
      allowLeadingZero: total > 0,
    );
    final value = total + lowerSection;
    return negative ? -value : value;
  }

  String _formatSection(int section, {required bool beforeSectionUnit}) {
    final buffer = StringBuffer();

    for (var position = 3; position >= 0; position -= 1) {
      final scale = _smallScales[position];
      final digit = section ~/ scale % 10;
      if (digit == 0) continue;

      final omitOne =
          digit == 1 && scale > 1 && !(beforeSectionUnit && scale == 1000);
      if (!omitOne) buffer.write(_digits[digit]);
      buffer.write(_smallUnits[position]);
    }

    return buffer.toString();
  }

  int _parseSection(
    String text,
    String input, {
    required bool allowEmptyAsOne,
    required bool allowLeadingZero,
  }) {
    if (text.isEmpty) return allowEmptyAsOne ? 1 : 0;

    var section = 0;
    int? pendingDigit;
    var lastUnit = 10000;
    var sawAny = false;
    var sawUnit = false;
    var zeroPending = false;
    var unitBeforeZero = 10000;
    int? zeroUnitBoundary;

    for (final char in text.runes.map(String.fromCharCode)) {
      final digit = _digitValues[char];
      if (digit != null) {
        if (digit == 0) {
          if (pendingDigit != null) {
            throw FormatException('Unexpected Japanese cardinal token.', input);
          }
          if (!sawAny && !allowLeadingZero) {
            throw FormatException('Unexpected Japanese cardinal token.', input);
          }
          pendingDigit = null;
          zeroPending = true;
          unitBeforeZero = lastUnit;
          zeroUnitBoundary = lastUnit;
          sawAny = true;
          continue;
        }

        if (pendingDigit != null) {
          throw FormatException('Unexpected Japanese cardinal token.', input);
        }
        if (zeroPending && unitBeforeZero <= 10) {
          throw FormatException('Unexpected Japanese cardinal token.', input);
        }

        pendingDigit = digit;
        zeroPending = false;
        sawAny = true;
        continue;
      }

      final unit = _smallUnitValues[char];
      if (unit == null) {
        throw FormatException('Unexpected Japanese cardinal token.', input);
      }
      if (unit >= lastUnit) {
        throw FormatException('Unexpected Japanese cardinal token.', input);
      }
      if (zeroPending && unitBeforeZero ~/ 10 == unit) {
        throw FormatException('Unexpected Japanese cardinal token.', input);
      }
      if (zeroUnitBoundary != null && zeroUnitBoundary ~/ 10 == unit) {
        throw FormatException('Unexpected Japanese cardinal token.', input);
      }

      final digitForUnit = pendingDigit ?? 1;
      if (digitForUnit == 0) {
        throw FormatException('Unexpected Japanese cardinal token.', input);
      }
      section += digitForUnit * unit;
      pendingDigit = null;
      lastUnit = unit;
      sawAny = true;
      sawUnit = true;
      zeroPending = false;
      zeroUnitBoundary = null;
    }

    if (zeroPending) {
      throw FormatException('Unexpected Japanese cardinal token.', input);
    }
    if (pendingDigit != null) {
      if (!sawUnit && section == 0 && _nonZeroDigitCount(text) > 1) {
        throw FormatException('Unexpected Japanese cardinal token.', input);
      }
      section += pendingDigit;
    }

    return section;
  }

  int _nonZeroDigitCount(String text) {
    var count = 0;
    for (final char in text.runes.map(String.fromCharCode)) {
      final digit = _digitValues[char];
      if (digit != null && digit != 0) count += 1;
    }
    return count;
  }
}
