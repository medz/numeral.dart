/// Simplified Chinese numerals language pack.
library;

import 'src/compact_codec.dart';
import 'src/language_pack.dart';
import 'src/numeral_codec.dart';
import 'src/rounding.dart';
import 'src/unit.dart';

/// Simplified Chinese numerals language pack.
const zh = ChineseNumerals();

/// Simplified Chinese compact units: `万`, `亿`, `兆`.
const chineseCompactUnits = NumeralUnitSet([
  NumeralUnit(1, ''),
  NumeralUnit(10000, '万'),
  NumeralUnit(100000000, '亿'),
  NumeralUnit(1000000000000, '兆'),
]);

/// Creates a Simplified Chinese compact number codec.
CompactCodec compact({
  String decimalSeparator = '.',
  int minFractionDigits = 0,
  int maxFractionDigits = 2,
  bool trimTrailingZeros = true,
  Rounding rounding = Rounding.halfUp,
  bool compactOverflow = true,
}) {
  return zh.compact(
    decimalSeparator: decimalSeparator,
    minFractionDigits: minFractionDigits,
    maxFractionDigits: maxFractionDigits,
    trimTrailingZeros: trimTrailingZeros,
    rounding: rounding,
    compactOverflow: compactOverflow,
  );
}

/// Creates a Simplified Chinese cardinal number codec.
ChineseCardinalCodec cardinal() => zh.cardinal();

/// Simplified Chinese numerals language pack.
final class ChineseNumerals implements NumeralLanguagePack {
  /// Creates a Simplified Chinese numerals language pack.
  const ChineseNumerals();

  @override
  String get locale => 'zh';

  @override
  NumeralUnitSet get compactUnits => chineseCompactUnits;

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

  /// Creates a Simplified Chinese cardinal number codec.
  ChineseCardinalCodec cardinal() => const ChineseCardinalCodec();
}

/// Converts integers to and from Simplified Chinese cardinal numerals.
final class ChineseCardinalCodec extends NumeralCodec<int> {
  /// Creates a Simplified Chinese cardinal codec.
  const ChineseCardinalCodec();

  static const _digits = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
  static const _smallUnits = ['', '十', '百', '千'];
  static const _sectionUnits = ['', '万', '亿', '兆', '京'];
  static const _digitValues = {
    '零': 0,
    '〇': 0,
    '一': 1,
    '二': 2,
    '两': 2,
    '三': 3,
    '四': 4,
    '五': 5,
    '六': 6,
    '七': 7,
    '八': 8,
    '九': 9,
  };
  static const _smallUnitValues = {
    '十': 10,
    '百': 100,
    '千': 1000,
  };
  static const _sectionUnitValues = {
    '万': 10000,
    '亿': 100000000,
    '兆': 1000000000000,
    '京': 10000000000000000,
  };

  @override
  String format(num value) {
    if (!value.isFinite || value % 1 != 0) {
      throw ArgumentError.value(value, 'value', 'Must be a finite integer.');
    }

    final integer = value.toInt();
    if (integer == 0) return _digits[0];
    if (integer < 0) return '负${format(-integer)}';

    final sections = <int>[];
    var rest = integer;
    while (rest > 0) {
      sections.add(rest % 10000);
      rest ~/= 10000;
    }

    final buffer = StringBuffer();
    var zeroPending = false;
    for (var index = sections.length - 1; index >= 0; index -= 1) {
      final section = sections[index];
      if (section == 0) {
        if (buffer.isNotEmpty) zeroPending = true;
        continue;
      }

      if (buffer.isNotEmpty && (zeroPending || section < 1000)) {
        buffer.write(_digits[0]);
      }

      buffer
        ..write(_formatSection(section))
        ..write(_sectionUnits[index]);
      zeroPending = false;
    }

    return buffer.toString();
  }

  @override
  int parse(String input) {
    var text = input.trim();
    if (text.isEmpty) {
      throw FormatException('Expected a Chinese cardinal number.', input);
    }

    final negative = text.startsWith('负');
    if (negative) {
      text = text.substring(1);
      if (text.isEmpty) {
        throw FormatException('Expected a Chinese cardinal number.', input);
      }
    }

    if (text == '零' || text == '〇') return 0;

    var total = 0;
    var section = 0;
    var number = 0;
    for (final char in text.runes.map(String.fromCharCode)) {
      final digit = _digitValues[char];
      if (digit != null) {
        number = digit;
        continue;
      }

      final smallUnit = _smallUnitValues[char];
      if (smallUnit != null) {
        section += (number == 0 ? 1 : number) * smallUnit;
        number = 0;
        continue;
      }

      final sectionUnit = _sectionUnitValues[char];
      if (sectionUnit != null) {
        section += number;
        number = 0;
        total += (section == 0 ? 1 : section) * sectionUnit;
        section = 0;
        continue;
      }

      throw FormatException('Unexpected Chinese cardinal token.', input);
    }

    final value = total + section + number;
    return negative ? -value : value;
  }

  String _formatSection(int section) {
    final buffer = StringBuffer();
    var zeroPending = false;

    for (var position = 3; position >= 0; position -= 1) {
      final unit = _pow10(position);
      final digit = section ~/ unit % 10;
      if (digit == 0) {
        if (buffer.isNotEmpty) zeroPending = true;
        continue;
      }

      if (zeroPending) {
        buffer.write(_digits[0]);
        zeroPending = false;
      }

      final omitLeadingOneForTen = digit == 1 && unit == 10 && buffer.isEmpty;
      if (!omitLeadingOneForTen) {
        buffer.write(_digits[digit]);
      }
      buffer.write(_smallUnits[position]);
    }

    return buffer.toString();
  }

  int _pow10(int exponent) {
    var value = 1;
    for (var index = 0; index < exponent; index += 1) {
      value *= 10;
    }
    return value;
  }
}
