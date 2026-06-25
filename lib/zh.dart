/// Simplified Chinese numerals language pack.
library;

import 'src/codec.dart';
import 'src/codec/compact.dart';
import 'src/language.dart';
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

/// Creates a Simplified Chinese year number codec.
ChineseYearCodec year({String suffix = ''}) => zh.year(suffix: suffix);

/// Creates a Simplified Chinese financial numeral codec.
ChineseFinancialCodec financial() => zh.financial();

/// Creates a Simplified Chinese RMB amount codec.
ChineseRmbCodec rmb({
  String prefix = '人民币',
  String wholeSuffix = '整',
  bool writeWholeSuffixForJiao = false,
}) {
  return zh.rmb(
    prefix: prefix,
    wholeSuffix: wholeSuffix,
    writeWholeSuffixForJiao: writeWholeSuffixForJiao,
  );
}

/// Simplified Chinese numerals language pack.
final class ChineseNumerals implements NumeralLanguage {
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

  /// Creates a Simplified Chinese year number codec.
  ChineseYearCodec year({String suffix = ''}) => ChineseYearCodec(
        suffix: suffix,
      );

  /// Creates a Simplified Chinese financial numeral codec.
  ChineseFinancialCodec financial() => const ChineseFinancialCodec();

  /// Creates a Simplified Chinese RMB amount codec.
  ChineseRmbCodec rmb({
    String prefix = '人民币',
    String wholeSuffix = '整',
    bool writeWholeSuffixForJiao = false,
  }) {
    return ChineseRmbCodec(
      prefix: prefix,
      wholeSuffix: wholeSuffix,
      writeWholeSuffixForJiao: writeWholeSuffixForJiao,
    );
  }
}

/// Converts years to and from Simplified Chinese digit-by-digit numerals.
final class ChineseYearCodec extends NumeralCodec<int> {
  /// Creates a Simplified Chinese year number codec.
  const ChineseYearCodec({this.suffix = ''});

  /// Text appended after the formatted year, such as `年`.
  final String suffix;

  static const _digits = ['〇', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
  static const _digitValues = {
    '〇': 0,
    '零': 0,
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

  @override
  String format(num value) {
    if (!value.isFinite || value % 1 != 0 || value < 0) {
      throw ArgumentError.value(
        value,
        'value',
        'Must be a non-negative finite integer.',
      );
    }

    final text = value.toInt().toString();
    final buffer = StringBuffer();
    for (final codeUnit in text.codeUnits) {
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
      throw FormatException('Expected a Chinese year number.', input);
    }

    final buffer = StringBuffer();
    for (final char in text.runes.map(String.fromCharCode)) {
      final value = _digitValues[char];
      if (value == null) {
        throw FormatException('Unexpected Chinese year token.', input);
      }
      buffer.write(value);
    }

    return int.parse(buffer.toString());
  }
}

/// Converts integers to and from Simplified Chinese cardinal numerals.
///
/// Formatting emits a normalized form with `二`. Parsing also accepts common
/// `两` variants, elided `一十` variants such as `一万零十`, and trailing-unit
/// omissions such as `一万二`.
final class ChineseCardinalCodec extends _ChineseSectionIntegerCodec {
  /// Creates a Simplified Chinese cardinal codec.
  const ChineseCardinalCodec()
      : super(
          digitSymbols: _digits,
          smallUnits: _smallUnits,
          sectionUnits: _sectionUnits,
          digitValues: _digitValues,
          smallUnitValues: _smallUnitValues,
          sectionUnitValues: _sectionUnitValues,
          expectedDescription: 'Chinese cardinal number',
          unexpectedDescription: 'Unexpected Chinese cardinal token.',
          omitLeadingOneForTen: true,
          allowImplicitOneForSmallUnit: true,
          allowTrailingUnitOmission: true,
        );

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
}

/// Converts integers to and from Simplified Chinese financial numerals.
final class ChineseFinancialCodec extends _ChineseSectionIntegerCodec {
  /// Creates a Simplified Chinese financial numeral codec.
  const ChineseFinancialCodec()
      : super(
          digitSymbols: digits,
          smallUnits: _smallUnits,
          sectionUnits: _sectionUnits,
          digitValues: _digitValues,
          smallUnitValues: _smallUnitValues,
          sectionUnitValues: _sectionUnitValues,
          expectedDescription: 'Chinese financial numeral',
          unexpectedDescription: 'Unexpected Chinese financial token.',
          allowImplicitOneForSmallUnit: false,
        );

  static const digits = ['零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖'];
  static const _smallUnits = ['', '拾', '佰', '仟'];
  static const _sectionUnits = ['', '万', '亿', '兆', '京'];
  static const _digitValues = {
    '零': 0,
    '壹': 1,
    '贰': 2,
    '貳': 2,
    '叁': 3,
    '參': 3,
    '肆': 4,
    '伍': 5,
    '陆': 6,
    '陸': 6,
    '柒': 7,
    '捌': 8,
    '玖': 9,
  };
  static const _smallUnitValues = {
    '拾': 10,
    '佰': 100,
    '仟': 1000,
  };
  static const _sectionUnitValues = {
    '万': 10000,
    '萬': 10000,
    '亿': 100000000,
    '億': 100000000,
    '兆': 1000000000000,
    '京': 10000000000000000,
  };
}

abstract base class _ChineseSectionIntegerCodec extends NumeralCodec<int> {
  const _ChineseSectionIntegerCodec({
    required this.digitSymbols,
    required this.smallUnits,
    required this.sectionUnits,
    required this.digitValues,
    required this.smallUnitValues,
    required this.sectionUnitValues,
    required this.expectedDescription,
    required this.unexpectedDescription,
    this.omitLeadingOneForTen = false,
    this.allowImplicitOneForSmallUnit = true,
    this.allowTrailingUnitOmission = false,
  });

  static const _smallScales = [1, 10, 100, 1000];
  static const _initialSmallUnit = 10000;
  static const _initialSectionUnit = 1000000000000000000;

  final List<String> digitSymbols;
  final List<String> smallUnits;
  final List<String> sectionUnits;
  final Map<String, int> digitValues;
  final Map<String, int> smallUnitValues;
  final Map<String, int> sectionUnitValues;
  final String expectedDescription;
  final String unexpectedDescription;
  final bool omitLeadingOneForTen;
  final bool allowImplicitOneForSmallUnit;
  final bool allowTrailingUnitOmission;

  @override
  String format(num value) {
    if (!value.isFinite || value % 1 != 0) {
      throw ArgumentError.value(value, 'value', 'Must be a finite integer.');
    }

    final integer = value.toInt();
    if (integer == 0) return digitSymbols[0];
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
        buffer.write(digitSymbols[0]);
      }

      final omitLeadingOne =
          omitLeadingOneForTen && buffer.isEmpty && section < 20;

      buffer
        ..write(_formatSection(section, omitLeadingOneForTen: omitLeadingOne))
        ..write(sectionUnits[index]);
      zeroPending = false;
    }

    return buffer.toString();
  }

  @override
  int parse(String input) {
    var text = input.trim();
    if (text.isEmpty) {
      throw FormatException('Expected a $expectedDescription.', input);
    }

    final negative = text.startsWith('负');
    if (negative) {
      text = text.substring(1);
      if (text.isEmpty) {
        throw FormatException('Expected a $expectedDescription.', input);
      }
    }

    if (text.runes.length == 1 &&
        digitValues[String.fromCharCode(text.runes.single)] == 0) {
      return 0;
    }

    var total = 0;
    var section = 0;
    int? number;
    var numberAfterZero = false;
    var numberIsAlternateTwo = false;
    var lastSmallUnit = _initialSmallUnit;
    var lastSectionUnit = _initialSectionUnit;
    for (final char in text.runes.map(String.fromCharCode)) {
      final digit = digitValues[char];
      if (digit != null) {
        if (number != null) {
          if (number == 0 && digit != 0 && (section > 0 || total > 0)) {
            number = digit;
            numberAfterZero = true;
            numberIsAlternateTwo = _isAlternateTwo(char);
            continue;
          }
          throw FormatException(unexpectedDescription, input);
        }
        number = digit;
        numberAfterZero = false;
        numberIsAlternateTwo = _isAlternateTwo(char);
        continue;
      }

      final smallUnit = smallUnitValues[char];
      if (smallUnit != null) {
        if (smallUnit >= lastSmallUnit) {
          throw FormatException(unexpectedDescription, input);
        }

        final digit = number;
        if ((digit == null || digit == 0) && !allowImplicitOneForSmallUnit) {
          throw FormatException(unexpectedDescription, input);
        }
        if (numberIsAlternateTwo && smallUnit == 10) {
          throw FormatException(unexpectedDescription, input);
        }
        if (digit == 0 && section == 0 && total == 0) {
          throw FormatException(unexpectedDescription, input);
        }

        section += (digit == null || digit == 0 ? 1 : digit) * smallUnit;
        number = null;
        numberAfterZero = false;
        numberIsAlternateTwo = false;
        lastSmallUnit = smallUnit;
        continue;
      }

      final sectionUnit = sectionUnitValues[char];
      if (sectionUnit != null) {
        if (sectionUnit >= lastSectionUnit) {
          throw FormatException(unexpectedDescription, input);
        }

        final digit = number;
        if (digit == 0) {
          throw FormatException(unexpectedDescription, input);
        }
        section += digit ?? 0;
        if (section == 0) {
          throw FormatException(unexpectedDescription, input);
        }

        total += section * sectionUnit;
        section = 0;
        number = null;
        numberAfterZero = false;
        numberIsAlternateTwo = false;
        lastSmallUnit = _initialSmallUnit;
        lastSectionUnit = sectionUnit;
        continue;
      }

      throw FormatException(unexpectedDescription, input);
    }

    if (number == 0) {
      throw FormatException(unexpectedDescription, input);
    }

    final trailing = number == null
        ? 0
        : _resolveTrailingNumber(
            number,
            numberAfterZero: numberAfterZero,
            lastSmallUnit: lastSmallUnit,
            lastSectionUnit: lastSectionUnit,
            input: input,
          );
    final value = total + section + trailing;
    return negative ? -value : value;
  }

  int _resolveTrailingNumber(
    int number, {
    required bool numberAfterZero,
    required int lastSmallUnit,
    required int lastSectionUnit,
    required String input,
  }) {
    final omittedScale = _trailingOmittedScale(lastSmallUnit, lastSectionUnit);
    if (!allowTrailingUnitOmission && !numberAfterZero && omittedScale > 1) {
      throw FormatException(unexpectedDescription, input);
    }
    if (!allowTrailingUnitOmission || numberAfterZero) return number;
    return number * omittedScale;
  }

  int _trailingOmittedScale(int lastSmallUnit, int lastSectionUnit) {
    if (lastSmallUnit < _initialSmallUnit) return lastSmallUnit ~/ 10;
    if (lastSectionUnit < _initialSectionUnit) return lastSectionUnit ~/ 10;
    return 1;
  }

  bool _isAlternateTwo(String char) => char == '两';

  String _formatSection(int section, {required bool omitLeadingOneForTen}) {
    final buffer = StringBuffer();
    var zeroPending = false;

    for (var position = 3; position >= 0; position -= 1) {
      final scale = _smallScales[position];
      final digit = section ~/ scale % 10;
      if (digit == 0) {
        if (buffer.isNotEmpty) zeroPending = true;
        continue;
      }

      if (zeroPending) {
        buffer.write(digitSymbols[0]);
        zeroPending = false;
      }

      final omitOne =
          omitLeadingOneForTen && digit == 1 && scale == 10 && buffer.isEmpty;
      if (!omitOne) {
        buffer.write(digitSymbols[digit]);
      }
      buffer.write(smallUnits[position]);
    }

    return buffer.toString();
  }
}

/// Converts RMB amounts to and from Simplified Chinese uppercase amount text.
final class ChineseRmbCodec extends NumeralCodec<num> {
  /// Creates a Simplified Chinese RMB amount codec.
  const ChineseRmbCodec({
    this.prefix = '人民币',
    this.wholeSuffix = '整',
    this.writeWholeSuffixForJiao = false,
  });

  /// Text written before the amount.
  final String prefix;

  /// Suffix written when the amount has no lower unit.
  ///
  /// Common values are `整` and `正`.
  final String wholeSuffix;

  /// Whether [wholeSuffix] is written after exact jiao amounts.
  final bool writeWholeSuffixForJiao;

  static const _financial = ChineseFinancialCodec();
  static final _leadingZeroPattern = RegExp('^零+');

  @override
  String format(num value) {
    final cents = _toCents(value);
    if (cents < 0) return '负${format(-cents / 100)}';

    final yuan = cents ~/ 100;
    final jiao = cents ~/ 10 % 10;
    final fen = cents % 10;
    final buffer = StringBuffer(prefix);

    if (yuan > 0 || (jiao == 0 && fen == 0)) {
      buffer
        ..write(_financial.format(yuan))
        ..write('元');
    }

    if (jiao == 0 && fen == 0) {
      buffer.write(wholeSuffix);
      return buffer.toString();
    }

    if (yuan > 0 && jiao == 0) {
      buffer.write('零');
    }

    if (jiao > 0) {
      buffer
        ..write(ChineseFinancialCodec.digits[jiao])
        ..write('角');
    }

    if (fen > 0) {
      buffer
        ..write(ChineseFinancialCodec.digits[fen])
        ..write('分');
    } else if (writeWholeSuffixForJiao) {
      buffer.write(wholeSuffix);
    }

    return buffer.toString();
  }

  @override
  num parse(String input) {
    var text = input.trim();
    if (text.isEmpty) {
      throw FormatException('Expected an RMB uppercase amount.', input);
    }

    final negative = text.startsWith('负');
    if (negative) {
      text = text.substring(1);
      if (text.isEmpty) {
        throw FormatException('Expected an RMB uppercase amount.', input);
      }
    }

    if (prefix.isNotEmpty && text.startsWith(prefix)) {
      text = text.substring(prefix.length);
    }

    if (text.endsWith(wholeSuffix)) {
      text = text.substring(0, text.length - wholeSuffix.length);
    } else if (text.endsWith('正')) {
      text = text.substring(0, text.length - 1);
    }

    if (text.isEmpty) {
      throw FormatException('Expected an RMB uppercase amount.', input);
    }

    var yuan = 0;
    var lower = text;
    final yuanIndex = text.indexOf('元');
    if (yuanIndex >= 0) {
      final yuanText = text.substring(0, yuanIndex);
      if (yuanText.isEmpty) {
        throw FormatException('Expected an RMB amount yuan value.', input);
      }
      yuan = _financial.parse(yuanText);
      lower = text.substring(yuanIndex + 1);
    }

    if (lower.contains('角') || lower.contains('分')) {
      lower = lower.replaceFirst(_leadingZeroPattern, '');
    } else if (lower.trim().isNotEmpty) {
      throw FormatException('Unexpected RMB amount token.', input);
    }

    var jiao = 0;
    var fen = 0;

    final jiaoIndex = lower.indexOf('角');
    if (jiaoIndex >= 0) {
      final jiaoText = lower.substring(0, jiaoIndex);
      jiao = _parseSingleDigit(jiaoText, input);
      lower = lower.substring(jiaoIndex + 1);
    }

    final fenIndex = lower.indexOf('分');
    if (fenIndex >= 0) {
      final fenText = lower.substring(0, fenIndex);
      fen = _parseSingleDigit(fenText, input);
      lower = lower.substring(fenIndex + 1);
    }

    if (lower.trim().isNotEmpty) {
      throw FormatException('Unexpected RMB amount token.', input);
    }

    final cents = yuan * 100 + jiao * 10 + fen;
    final value = cents % 100 == 0 ? cents ~/ 100 : cents / 100;
    return negative ? -value : value;
  }

  int _toCents(num value) {
    if (!value.isFinite) {
      throw ArgumentError.value(value, 'value', 'Must be finite.');
    }

    var text = value.toString();
    final negative = text.startsWith('-');
    if (negative) text = text.substring(1);

    if (text.contains('e') || text.contains('E')) {
      final scaled = value * 100;
      final cents = scaled.round();
      if ((scaled - cents).abs() <= 1e-7) return cents;
      throw ArgumentError.value(
        value,
        'value',
        'Must have no more than two decimal places.',
      );
    }

    final parts = text.split('.');
    final whole = int.parse(parts.first);
    var fraction = parts.length == 1 ? '' : parts.last;
    while (fraction.endsWith('0')) {
      fraction = fraction.substring(0, fraction.length - 1);
    }

    if (fraction.length > 2) {
      throw ArgumentError.value(
        value,
        'value',
        'Must have no more than two decimal places.',
      );
    }

    final cents = whole * 100 + int.parse(fraction.padRight(2, '0'));
    return negative ? -cents : cents;
  }

  int _parseSingleDigit(String text, String input) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw FormatException('Expected an RMB amount digit.', input);
    }
    final value = ChineseFinancialCodec._digitValues[trimmed];
    if (value == null || value == 0) {
      throw FormatException('Expected a non-zero RMB amount digit.', input);
    }
    return value;
  }
}
