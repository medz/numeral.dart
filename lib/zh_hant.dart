/// Traditional Chinese numerals language pack.
library;

import 'src/codec.dart';
import 'src/codec/compact.dart';
import 'src/language.dart';
import 'src/rounding.dart';
import 'src/unit.dart';
import 'zh.dart' as zh;

String _toTraditional(String input) {
  return input
      .replaceAll('负', '負')
      .replaceAll('万', '萬')
      .replaceAll('亿', '億')
      .replaceAll('两', '兩')
      .replaceAll('贰', '貳')
      .replaceAll('叁', '參')
      .replaceAll('陆', '陸');
}

String _toSimplified(String input) {
  return input
      .replaceAll('負', '负')
      .replaceAll('萬', '万')
      .replaceAll('億', '亿')
      .replaceAll('兩', '两')
      .replaceAll('貳', '贰')
      .replaceAll('貮', '贰')
      .replaceAll('參', '叁')
      .replaceAll('参', '叁')
      .replaceAll('陸', '陆');
}

/// Traditional Chinese numerals language pack.
const zhHant = TraditionalChineseNumerals();

/// Traditional Chinese compact units: `萬`, `億`, `兆`.
const traditionalChineseCompactUnits = NumeralUnitSet([
  NumeralUnit(1, ''),
  NumeralUnit(10000, '萬', aliases: ['万']),
  NumeralUnit(100000000, '億', aliases: ['亿']),
  NumeralUnit(1000000000000, '兆'),
]);

/// Creates a Traditional Chinese compact number codec.
CompactCodec compact({
  String decimalSeparator = '.',
  int minFractionDigits = 0,
  int maxFractionDigits = 2,
  bool trimTrailingZeros = true,
  Rounding rounding = Rounding.halfUp,
  bool compactOverflow = true,
}) {
  return zhHant.compact(
    decimalSeparator: decimalSeparator,
    minFractionDigits: minFractionDigits,
    maxFractionDigits: maxFractionDigits,
    trimTrailingZeros: trimTrailingZeros,
    rounding: rounding,
    compactOverflow: compactOverflow,
  );
}

/// Creates a Traditional Chinese cardinal number codec.
TraditionalChineseCardinalCodec cardinal() => zhHant.cardinal();

/// Creates a Traditional Chinese year number codec.
TraditionalChineseYearCodec year({String suffix = ''}) {
  return zhHant.year(suffix: suffix);
}

/// Creates a Traditional Chinese financial numeral codec.
TraditionalChineseFinancialCodec financial() => zhHant.financial();

/// Traditional Chinese numerals language pack.
final class TraditionalChineseNumerals implements NumeralLanguage {
  /// Creates a Traditional Chinese numerals language pack.
  const TraditionalChineseNumerals();

  @override
  String get locale => 'zh-Hant';

  @override
  NumeralUnitSet get compactUnits => traditionalChineseCompactUnits;

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

  /// Creates a Traditional Chinese cardinal number codec.
  TraditionalChineseCardinalCodec cardinal() {
    return const TraditionalChineseCardinalCodec();
  }

  /// Creates a Traditional Chinese year number codec.
  TraditionalChineseYearCodec year({String suffix = ''}) {
    return TraditionalChineseYearCodec(suffix: suffix);
  }

  /// Creates a Traditional Chinese financial numeral codec.
  TraditionalChineseFinancialCodec financial() {
    return const TraditionalChineseFinancialCodec();
  }
}

/// Converts integers to and from Traditional Chinese cardinal numerals.
///
/// Formatting emits normalized Traditional Chinese text. Parsing also accepts
/// common Simplified Chinese characters and `兩` variants.
final class TraditionalChineseCardinalCodec extends NumeralCodec<int> {
  /// Creates a Traditional Chinese cardinal codec.
  const TraditionalChineseCardinalCodec();

  static const _delegate = zh.ChineseCardinalCodec();

  @override
  String format(num value) => _toTraditional(_delegate.format(value));

  @override
  int parse(String input) => _delegate.parse(_toSimplified(input));
}

/// Converts years to and from Traditional Chinese digit-by-digit numerals.
final class TraditionalChineseYearCodec extends NumeralCodec<int> {
  /// Creates a Traditional Chinese year number codec.
  const TraditionalChineseYearCodec({this.suffix = ''});

  /// Text appended after the formatted year, such as `年`.
  final String suffix;

  @override
  String format(num value) {
    return zh.ChineseYearCodec(suffix: suffix).format(value);
  }

  @override
  int parse(String input) {
    final normalized = input.replaceAll('兩', '两');
    return zh.ChineseYearCodec(suffix: suffix).parse(normalized);
  }
}

/// Converts integers to and from Traditional Chinese financial numerals.
///
/// Formatting emits `貳`, `參`, `陸`, `萬`, and `億`. Parsing also accepts
/// Simplified Chinese financial variants.
final class TraditionalChineseFinancialCodec extends NumeralCodec<int> {
  /// Creates a Traditional Chinese financial numeral codec.
  const TraditionalChineseFinancialCodec();

  static const _delegate = zh.ChineseFinancialCodec();

  @override
  String format(num value) => _toTraditional(_delegate.format(value));

  @override
  int parse(String input) => _delegate.parse(_toSimplified(input));
}
