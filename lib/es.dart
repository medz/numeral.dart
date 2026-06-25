/// Spanish numerals language pack.
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

/// Spanish numerals language pack.
const es = SpanishNumerals();

/// Spanish compact units: `mil`, `M`, `B`.
///
/// Spanish uses the long scale: `billón` is 10^12, while 10^9 is commonly
/// written as `mil millones`.
const spanishCompactUnits = NumeralUnitSet([
  NumeralUnit(1, ''),
  NumeralUnit(1000, 'mil', aliases: ['K', 'k'], space: true),
  NumeralUnit(
    1000000,
    'M',
    aliases: ['m', 'millón', 'millon', 'millones'],
    space: true,
  ),
  NumeralUnit(
    1000000000000,
    'B',
    aliases: ['b', 'billón', 'billon', 'billones'],
    space: true,
  ),
]);

/// Creates a Spanish compact number codec.
CompactCodec compact({
  String decimalSeparator = ',',
  int minFractionDigits = 0,
  int maxFractionDigits = 2,
  bool trimTrailingZeros = true,
  Rounding rounding = Rounding.halfUp,
  bool compactOverflow = true,
}) {
  return es.compact(
    decimalSeparator: decimalSeparator,
    minFractionDigits: minFractionDigits,
    maxFractionDigits: maxFractionDigits,
    trimTrailingZeros: trimTrailingZeros,
    rounding: rounding,
    compactOverflow: compactOverflow,
  );
}

/// Creates a Spanish cardinal number codec.
SpanishCardinalCodec cardinal() => es.cardinal();

/// Spanish numerals language pack.
final class SpanishNumerals implements NumeralLanguage {
  /// Creates a Spanish numerals language pack.
  const SpanishNumerals();

  @override
  String get locale => 'es';

  @override
  NumeralUnitSet get compactUnits => spanishCompactUnits;

  @override
  CompactCodec compact({
    String decimalSeparator = ',',
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

  /// Creates a Spanish cardinal number codec.
  SpanishCardinalCodec cardinal() => const SpanishCardinalCodec();
}

/// Converts integers to and from Spanish cardinal numerals.
///
/// Formatting emits normalized masculine standalone Spanish cardinal text.
/// Parsing accepts common accentless spellings and `un` / `uno` variants.
final class SpanishCardinalCodec extends NumeralCodec<int> {
  /// Creates a Spanish cardinal codec.
  const SpanishCardinalCodec();

  static const _maxValue = 999999999999999999;
  static const _million = 1000000;
  static const _billion = 1000000000000;
  static const _units = [
    'cero',
    'uno',
    'dos',
    'tres',
    'cuatro',
    'cinco',
    'seis',
    'siete',
    'ocho',
    'nueve',
    'diez',
    'once',
    'doce',
    'trece',
    'catorce',
    'quince',
    'dieciséis',
    'diecisiete',
    'dieciocho',
    'diecinueve',
    'veinte',
    'veintiuno',
    'veintidós',
    'veintitrés',
    'veinticuatro',
    'veinticinco',
    'veintiséis',
    'veintisiete',
    'veintiocho',
    'veintinueve',
  ];
  static const _tens = {
    30: 'treinta',
    40: 'cuarenta',
    50: 'cincuenta',
    60: 'sesenta',
    70: 'setenta',
    80: 'ochenta',
    90: 'noventa',
  };
  static const _hundreds = {
    200: 'doscientos',
    300: 'trescientos',
    400: 'cuatrocientos',
    500: 'quinientos',
    600: 'seiscientos',
    700: 'setecientos',
    800: 'ochocientos',
    900: 'novecientos',
  };

  static const _unitValues = {
    'cero': 0,
    'un': 1,
    'uno': 1,
    'una': 1,
    'dos': 2,
    'tres': 3,
    'cuatro': 4,
    'cinco': 5,
    'seis': 6,
    'siete': 7,
    'ocho': 8,
    'nueve': 9,
    'diez': 10,
    'once': 11,
    'doce': 12,
    'trece': 13,
    'catorce': 14,
    'quince': 15,
    'dieciseis': 16,
    'diecisiete': 17,
    'dieciocho': 18,
    'diecinueve': 19,
    'veinte': 20,
    'veintiun': 21,
    'veintiuno': 21,
    'veintiuna': 21,
    'veintidos': 22,
    'veintitres': 23,
    'veinticuatro': 24,
    'veinticinco': 25,
    'veintiseis': 26,
    'veintisiete': 27,
    'veintiocho': 28,
    'veintinueve': 29,
  };
  static const _tensValues = {
    'treinta': 30,
    'cuarenta': 40,
    'cincuenta': 50,
    'sesenta': 60,
    'setenta': 70,
    'ochenta': 80,
    'noventa': 90,
  };
  static const _hundredValues = {
    'cien': 100,
    'ciento': 100,
    'doscientos': 200,
    'doscientas': 200,
    'trescientos': 300,
    'trescientas': 300,
    'cuatrocientos': 400,
    'cuatrocientas': 400,
    'quinientos': 500,
    'quinientas': 500,
    'seiscientos': 600,
    'seiscientas': 600,
    'setecientos': 700,
    'setecientas': 700,
    'ochocientos': 800,
    'ochocientas': 800,
    'novecientos': 900,
    'novecientas': 900,
  };

  @override
  String format(num value) {
    final integer = _checkedInteger(value, 'Must be a finite integer.');
    if (integer > _maxValue || integer < -_maxValue) {
      throw ArgumentError.value(
        value,
        'value',
        'Exceeds supported Spanish cardinal range.',
      );
    }
    if (integer == 0) return 'cero';
    if (integer < 0) return 'menos ${format(-integer)}';
    return _formatPositive(integer);
  }

  @override
  int parse(String input) {
    var text = _normalize(input);
    if (text.isEmpty) {
      throw FormatException('Expected a Spanish cardinal number.', input);
    }

    var negative = false;
    if (text.startsWith('menos ')) {
      negative = true;
      text = text.substring('menos '.length);
      if (text.isEmpty) {
        throw FormatException('Expected a Spanish cardinal number.', input);
      }
    }

    final tokens = text.split(' ');
    if (tokens.length == 1 && tokens.single == 'cero') return 0;
    if (tokens.contains('cero')) {
      throw FormatException('Unexpected Spanish cardinal token.', input);
    }

    final value = _parseLarge(tokens, input, _billion * 1000000);
    if (value == 0 || value > _maxValue) {
      throw FormatException('Unexpected Spanish cardinal token.', input);
    }
    return negative ? -value : value;
  }

  String _formatPositive(int value) {
    final parts = <String>[];
    var rest = value;

    final billones = rest ~/ _billion;
    rest %= _billion;
    if (billones > 0) {
      parts.add(_formatScale(billones, singular: 'billón', plural: 'billones'));
    }

    final millones = rest ~/ _million;
    rest %= _million;
    if (millones > 0) {
      parts.add(_formatScale(millones, singular: 'millón', plural: 'millones'));
    }

    if (rest > 0) {
      parts.add(_formatBelowMillion(rest));
    }

    return parts.join(' ');
  }

  String _formatScale(
    int count, {
    required String singular,
    required String plural,
  }) {
    if (count == 1) return 'un $singular';
    return '${_apocopate(_formatBelowMillion(count))} $plural';
  }

  String _formatBelowMillion(int value) {
    final parts = <String>[];
    final thousands = value ~/ 1000;
    final rest = value % 1000;

    if (thousands == 1) {
      parts.add('mil');
    } else if (thousands > 1) {
      parts.add('${_apocopate(_formatBelowThousand(thousands))} mil');
    }

    if (rest > 0) {
      parts.add(_formatBelowThousand(rest));
    }

    return parts.join(' ');
  }

  String _formatBelowThousand(int value) {
    if (value < 30) return _units[value];
    if (value < 100) {
      final ten = value ~/ 10 * 10;
      final unit = value % 10;
      final tenText = _tens[ten]!;
      if (unit == 0) return tenText;
      return '$tenText y ${_units[unit]}';
    }
    if (value == 100) return 'cien';
    if (value < 200) return 'ciento ${_formatBelowThousand(value - 100)}';

    final hundred = value ~/ 100 * 100;
    final rest = value % 100;
    final hundredText = _hundreds[hundred]!;
    if (rest == 0) return hundredText;
    return '$hundredText ${_formatBelowThousand(rest)}';
  }

  String _apocopate(String text) {
    if (text == 'uno') return 'un';
    if (text.endsWith('veintiuno')) {
      return '${text.substring(0, text.length - 'veintiuno'.length)}veintiún';
    }
    if (text.endsWith(' uno')) {
      return '${text.substring(0, text.length - ' uno'.length)} un';
    }
    return text;
  }

  int _parseLarge(List<String> tokens, String input, int maxScale) {
    if (tokens.isEmpty) return 0;

    final billionIndex = _indexOfAny(tokens, const ['billon', 'billones']);
    if (billionIndex >= 0) {
      if (_billion >= maxScale) {
        throw FormatException('Unexpected Spanish cardinal token.', input);
      }
      final count = _parseScaleCount(
        tokens.sublist(0, billionIndex),
        input,
        singular: tokens[billionIndex] == 'billon',
      );
      final rest = _parseLarge(
        tokens.sublist(billionIndex + 1),
        input,
        _billion,
      );
      return count * _billion + rest;
    }

    final millionIndex = _indexOfAny(tokens, const ['millon', 'millones']);
    if (millionIndex >= 0) {
      if (_million >= maxScale) {
        throw FormatException('Unexpected Spanish cardinal token.', input);
      }
      final count = _parseScaleCount(
        tokens.sublist(0, millionIndex),
        input,
        singular: tokens[millionIndex] == 'millon',
      );
      final rest = _parseLarge(
        tokens.sublist(millionIndex + 1),
        input,
        _million,
      );
      return count * _million + rest;
    }

    return _parseBelowMillion(tokens, input);
  }

  int _parseScaleCount(
    List<String> tokens,
    String input, {
    required bool singular,
  }) {
    if (tokens.isEmpty) {
      throw FormatException('Unexpected Spanish cardinal token.', input);
    }
    final count = _parseBelowMillion(tokens, input);
    if (count == 0) {
      throw FormatException('Unexpected Spanish cardinal token.', input);
    }
    if (singular && count != 1) {
      throw FormatException('Unexpected Spanish cardinal token.', input);
    }
    if (!singular && count == 1) {
      throw FormatException('Unexpected Spanish cardinal token.', input);
    }
    return count;
  }

  int _parseBelowMillion(List<String> tokens, String input) {
    if (tokens.isEmpty) return 0;

    final thousandIndex = tokens.indexOf('mil');
    if (thousandIndex < 0) return _parseBelowThousand(tokens, input);
    if (tokens.indexOf('mil', thousandIndex + 1) >= 0) {
      throw FormatException('Unexpected Spanish cardinal token.', input);
    }

    final left = tokens.sublist(0, thousandIndex);
    final right = tokens.sublist(thousandIndex + 1);
    final thousands = left.isEmpty ? 1 : _parseBelowThousand(left, input);
    if (thousands == 0) {
      throw FormatException('Unexpected Spanish cardinal token.', input);
    }
    final rest = right.isEmpty ? 0 : _parseBelowThousand(right, input);
    return thousands * 1000 + rest;
  }

  int _parseBelowThousand(List<String> tokens, String input) {
    if (tokens.isEmpty) return 0;

    final first = tokens.first;
    final hundred = _hundredValues[first];
    if (hundred != null) {
      if (first == 'cien') {
        if (tokens.length == 1) return 100;
        throw FormatException('Unexpected Spanish cardinal token.', input);
      }
      final rest = _parseBelowHundred(tokens.sublist(1), input);
      if (rest == 0) {
        if (first == 'ciento') {
          throw FormatException('Unexpected Spanish cardinal token.', input);
        }
        return hundred;
      }
      return hundred + rest;
    }

    return _parseBelowHundred(tokens, input);
  }

  int _parseBelowHundred(List<String> tokens, String input) {
    if (tokens.isEmpty) return 0;
    if (tokens.length == 1) {
      final direct = _unitValues[tokens.single] ?? _tensValues[tokens.single];
      if (direct == null) {
        throw FormatException('Unexpected Spanish cardinal token.', input);
      }
      return direct;
    }

    if (tokens.length == 3 && tokens[1] == 'y') {
      final ten = _tensValues[tokens.first];
      final unit = _unitValues[tokens.last];
      if (ten != null && unit != null && unit > 0 && unit < 10) {
        return ten + unit;
      }
    }

    throw FormatException('Unexpected Spanish cardinal token.', input);
  }

  int _indexOfAny(List<String> tokens, List<String> values) {
    for (var index = 0; index < tokens.length; index += 1) {
      if (values.contains(tokens[index])) return index;
    }
    return -1;
  }

  String _normalize(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll(RegExp(r'[-_]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
