/// Korean numerals language pack.
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

/// Korean numerals language pack.
const ko = KoreanNumerals();

/// Korean compact units: `만`, `억`, `조`.
const koreanCompactUnits = NumeralUnitSet([
  NumeralUnit(1, ''),
  NumeralUnit(1000, '천', aliases: ['千']),
  NumeralUnit(10000, '만', aliases: ['萬', '万']),
  NumeralUnit(100000000, '억', aliases: ['億']),
  NumeralUnit(1000000000000, '조', aliases: ['兆']),
]);

/// Creates a Korean compact number codec.
CompactCodec compact({
  String decimalSeparator = '.',
  int minFractionDigits = 0,
  int maxFractionDigits = 2,
  bool trimTrailingZeros = true,
  Rounding rounding = Rounding.halfUp,
  bool compactOverflow = true,
}) {
  return ko.compact(
    decimalSeparator: decimalSeparator,
    minFractionDigits: minFractionDigits,
    maxFractionDigits: maxFractionDigits,
    trimTrailingZeros: trimTrailingZeros,
    rounding: rounding,
    compactOverflow: compactOverflow,
  );
}

/// Creates a Sino-Korean cardinal number codec.
KoreanCardinalCodec cardinal() => ko.cardinal();

/// Creates a Korean year number codec.
KoreanYearCodec year({String suffix = ''}) => ko.year(suffix: suffix);

/// Korean numerals language pack.
final class KoreanNumerals implements NumeralLanguage {
  /// Creates a Korean numerals language pack.
  const KoreanNumerals();

  @override
  String get locale => 'ko';

  @override
  NumeralUnitSet get compactUnits => koreanCompactUnits;

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

  /// Creates a Sino-Korean cardinal number codec.
  KoreanCardinalCodec cardinal() => const KoreanCardinalCodec();

  /// Creates a Korean year number codec.
  KoreanYearCodec year({String suffix = ''}) => KoreanYearCodec(
        suffix: suffix,
      );
}

/// Converts integers to and from Sino-Korean cardinal numerals.
///
/// Formatting emits normalized Hangul text. Parsing also accepts common Hanja
/// and financial Hanja variants.
final class KoreanCardinalCodec extends NumeralCodec<int> {
  /// Creates a Sino-Korean cardinal codec.
  const KoreanCardinalCodec();

  static const _digits = ['영', '일', '이', '삼', '사', '오', '육', '칠', '팔', '구'];
  static const _smallUnits = ['', '십', '백', '천'];
  static const _sectionUnits = ['', '만', '억', '조', '경'];
  static const _smallScales = [1, 10, 100, 1000];
  static const _digitValues = {
    '영': 0,
    '령': 0,
    '공': 0,
    '零': 0,
    '空': 0,
    '일': 1,
    '一': 1,
    '壹': 1,
    '이': 2,
    '二': 2,
    '貳': 2,
    '贰': 2,
    '삼': 3,
    '三': 3,
    '參': 3,
    '参': 3,
    '叁': 3,
    '사': 4,
    '四': 4,
    '肆': 4,
    '오': 5,
    '五': 5,
    '伍': 5,
    '육': 6,
    '륙': 6,
    '六': 6,
    '陸': 6,
    '陆': 6,
    '칠': 7,
    '七': 7,
    '柒': 7,
    '팔': 8,
    '八': 8,
    '捌': 8,
    '구': 9,
    '九': 9,
    '玖': 9,
  };
  static const _smallUnitValues = {
    '십': 10,
    '十': 10,
    '拾': 10,
    '백': 100,
    '百': 100,
    '佰': 100,
    '천': 1000,
    '千': 1000,
    '仟': 1000,
    '阡': 1000,
  };
  static const _sectionUnitValues = {
    '만': 10000,
    '萬': 10000,
    '万': 10000,
    '억': 100000000,
    '億': 100000000,
    '조': 1000000000000,
    '兆': 1000000000000,
    '경': 10000000000000000,
    '京': 10000000000000000,
  };

  @override
  String format(num value) {
    final integer = _checkedInteger(value, 'Must be a finite integer.');
    if (integer == 0) return _digits[0];
    if (integer < 0) return '마이너스${format(-integer)}';

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
        'Exceeds supported Korean section units.',
      );
    }

    final buffer = StringBuffer();
    for (var index = sections.length - 1; index >= 0; index -= 1) {
      final section = sections[index];
      if (section == 0) continue;

      final omitOneBeforeSectionUnit = index == 1 && section == 1;
      if (!omitOneBeforeSectionUnit) {
        buffer.write(_formatSection(section));
      }
      buffer.write(_sectionUnits[index]);
    }

    return buffer.toString();
  }

  @override
  int parse(String input) {
    var text = input.trim().replaceAll(RegExp(r'\s+'), '');
    if (text.isEmpty) {
      throw FormatException('Expected a Korean cardinal number.', input);
    }

    var negative = false;
    if (text.startsWith('마이너스')) {
      negative = true;
      text = text.substring('마이너스'.length);
    } else if (text.startsWith('-')) {
      negative = true;
      text = text.substring(1);
    }
    if (text.isEmpty) {
      throw FormatException('Expected a Korean cardinal number.', input);
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
        throw FormatException('Unexpected Korean cardinal token.', input);
      }

      final rawSection = sectionText.toString();
      if (rawSection.isEmpty && total > 0) {
        throw FormatException('Unexpected Korean cardinal token.', input);
      }

      final section = _parseSection(
        rawSection,
        input,
        allowEmptyAsOne: true,
        allowLeadingZero: false,
      );
      if (section == 0) {
        throw FormatException('Unexpected Korean cardinal token.', input);
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

  String _formatSection(int section) {
    final buffer = StringBuffer();

    for (var position = 3; position >= 0; position -= 1) {
      final scale = _smallScales[position];
      final digit = section ~/ scale % 10;
      if (digit == 0) continue;

      final omitOne = digit == 1 && scale > 1;
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

    for (final char in text.runes.map(String.fromCharCode)) {
      final digit = _digitValues[char];
      if (digit != null) {
        if (digit == 0) {
          if (pendingDigit != null) {
            throw FormatException('Unexpected Korean cardinal token.', input);
          }
          if (!sawAny && !allowLeadingZero) {
            throw FormatException('Unexpected Korean cardinal token.', input);
          }
          zeroPending = true;
          unitBeforeZero = lastUnit;
          sawAny = true;
          continue;
        }

        if (pendingDigit != null) {
          throw FormatException('Unexpected Korean cardinal token.', input);
        }
        if (zeroPending && unitBeforeZero <= 10) {
          throw FormatException('Unexpected Korean cardinal token.', input);
        }

        pendingDigit = digit;
        zeroPending = false;
        sawAny = true;
        continue;
      }

      final unit = _smallUnitValues[char];
      if (unit == null) {
        throw FormatException('Unexpected Korean cardinal token.', input);
      }
      if (unit >= lastUnit ||
          (zeroPending && (!allowLeadingZero || section > 0 || sawUnit))) {
        throw FormatException('Unexpected Korean cardinal token.', input);
      }

      final digitForUnit = pendingDigit ?? 1;
      if (digitForUnit == 0) {
        throw FormatException('Unexpected Korean cardinal token.', input);
      }
      section += digitForUnit * unit;
      pendingDigit = null;
      lastUnit = unit;
      sawAny = true;
      sawUnit = true;
      zeroPending = false;
    }

    if (zeroPending) {
      throw FormatException('Unexpected Korean cardinal token.', input);
    }
    if (pendingDigit != null) {
      if (!sawUnit && section == 0 && _nonZeroDigitCount(text) > 1) {
        throw FormatException('Unexpected Korean cardinal token.', input);
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

/// Converts years to and from Sino-Korean year numerals.
final class KoreanYearCodec extends NumeralCodec<int> {
  /// Creates a Korean year number codec.
  const KoreanYearCodec({this.suffix = ''});

  /// Text appended after the formatted year, such as `년`.
  final String suffix;

  static const _cardinal = KoreanCardinalCodec();

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

    return '${_cardinal.format(integer)}$suffix';
  }

  @override
  int parse(String input) {
    var text = input.trim();
    if (suffix.isNotEmpty) {
      if (!text.endsWith(suffix)) {
        throw FormatException('Expected year suffix "$suffix".', input);
      }
      text = text.substring(0, text.length - suffix.length);
    } else if (text.endsWith('년')) {
      text = text.substring(0, text.length - 1);
    }

    final value = _cardinal.parse(text);
    if (value < 0) {
      throw FormatException(
        'Expected a non-negative Korean year number.',
        input,
      );
    }
    return value;
  }
}
