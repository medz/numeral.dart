/// French numerals language pack.
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

/// French numerals language pack.
const fr = FrenchNumerals();

/// French compact units: `k`, `M`, `Md`, `Bn`.
const frenchCompactUnits = NumeralUnitSet([
  NumeralUnit(1, ''),
  NumeralUnit(1000, 'k', aliases: ['K', 'mille'], space: true),
  NumeralUnit(
    1000000,
    'M',
    aliases: ['m', 'million', 'millions'],
    space: true,
  ),
  NumeralUnit(
    1000000000,
    'Md',
    aliases: ['md', 'milliard', 'milliards'],
    space: true,
  ),
  NumeralUnit(
    1000000000000,
    'Bn',
    aliases: ['bn', 'billion', 'billions'],
    space: true,
  ),
]);

/// Creates a French compact number codec.
CompactCodec compact({
  String decimalSeparator = ',',
  int minFractionDigits = 0,
  int maxFractionDigits = 2,
  bool trimTrailingZeros = true,
  Rounding rounding = Rounding.halfUp,
  bool compactOverflow = true,
}) {
  return fr.compact(
    decimalSeparator: decimalSeparator,
    minFractionDigits: minFractionDigits,
    maxFractionDigits: maxFractionDigits,
    trimTrailingZeros: trimTrailingZeros,
    rounding: rounding,
    compactOverflow: compactOverflow,
  );
}

/// Creates a French cardinal number codec.
FrenchCardinalCodec cardinal() => fr.cardinal();

/// Creates a French year number codec.
FrenchYearCodec year({String suffix = ''}) => fr.year(suffix: suffix);

/// French numerals language pack.
final class FrenchNumerals implements NumeralLanguage {
  /// Creates a French numerals language pack.
  const FrenchNumerals();

  @override
  String get locale => 'fr';

  @override
  NumeralUnitSet get compactUnits => frenchCompactUnits;

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

  /// Creates a French cardinal number codec.
  FrenchCardinalCodec cardinal() => const FrenchCardinalCodec();

  /// Creates a French year number codec.
  FrenchYearCodec year({String suffix = ''}) => FrenchYearCodec(
        suffix: suffix,
      );
}

/// Converts integers to and from French cardinal numerals.
///
/// Formatting emits the post-1990 hyphenated spelling, such as
/// `vingt-et-un`, `soixante-et-onze`, and `quatre-vingt-un`. Parsing accepts
/// the same words separated by hyphens or spaces.
final class FrenchCardinalCodec extends NumeralCodec<int> {
  /// Creates a French cardinal codec.
  const FrenchCardinalCodec();

  static const _maxValue = 999999999999999999;
  static const _largeScales = [
    _FrenchScale(1000000000000000, 'billiard'),
    _FrenchScale(1000000000000, 'billion'),
    _FrenchScale(1000000000, 'milliard'),
    _FrenchScale(1000000, 'million'),
    _FrenchScale(1000, 'mille'),
  ];
  static const _smallWords = [
    'zéro',
    'un',
    'deux',
    'trois',
    'quatre',
    'cinq',
    'six',
    'sept',
    'huit',
    'neuf',
    'dix',
    'onze',
    'douze',
    'treize',
    'quatorze',
    'quinze',
    'seize',
  ];
  static const _tensWords = {
    20: 'vingt',
    30: 'trente',
    40: 'quarante',
    50: 'cinquante',
    60: 'soixante',
  };
  static const _digitValues = {
    'un': 1,
    'une': 1,
    'deux': 2,
    'trois': 3,
    'quatre': 4,
    'cinq': 5,
    'six': 6,
    'sept': 7,
    'huit': 8,
    'neuf': 9,
  };
  static const _scaleValues = {
    'billiard': 1000000000000000,
    'billiards': 1000000000000000,
    'billion': 1000000000000,
    'billions': 1000000000000,
    'milliard': 1000000000,
    'milliards': 1000000000,
    'million': 1000000,
    'millions': 1000000,
    'mille': 1000,
  };

  static final Map<String, int> _belowHundredValues =
      _buildBelowHundredValues();

  @override
  String format(num value) {
    final integer = _checkedInteger(value, 'Must be a finite integer.');
    if (integer > _maxValue || integer < -_maxValue) {
      throw ArgumentError.value(
        value,
        'value',
        'Exceeds supported French cardinal range.',
      );
    }
    if (integer == 0) return _smallWords[0];
    if (integer < 0) return 'moins-${format(-integer)}';
    return _formatPositive(integer);
  }

  @override
  int parse(String input) {
    var text = _normalize(input);
    if (text.isEmpty) {
      throw FormatException('Expected a French cardinal number.', input);
    }

    var negative = false;
    if (text == 'moins') {
      throw FormatException('Expected a French cardinal number.', input);
    }
    if (text.startsWith('moins ')) {
      negative = true;
      text = text.substring('moins '.length);
      if (text.isEmpty) {
        throw FormatException('Expected a French cardinal number.', input);
      }
    }

    final tokens = text.split(' ');
    if (tokens.length == 1 && _isZero(tokens.single)) return 0;
    if (tokens.any(_isZero)) {
      throw FormatException('Unexpected French cardinal token.', input);
    }

    final value = _parsePositive(tokens, input);
    if (value == 0 || value > _maxValue) {
      throw FormatException('Unexpected French cardinal token.', input);
    }
    return negative ? -value : value;
  }

  String _formatPositive(int value) {
    if (value < 1000) return _formatBelowThousand(value);

    final parts = <String>[];
    var rest = value;
    for (final scale in _largeScales) {
      final count = rest ~/ scale.value;
      if (count == 0) continue;

      if (scale.value == 1000 && count == 1) {
        parts.add('mille');
      } else {
        final plural = count > 1 && scale.value != 1000;
        final unit = plural ? '${scale.name}s' : scale.name;
        final countText = scale.value == 1000
            ? _dropTerminalPlural(_formatPositive(count))
            : _formatPositive(count);
        parts.add('$countText-$unit');
      }
      rest %= scale.value;
    }

    if (rest > 0) {
      parts.add(_formatBelowThousand(rest));
    }
    return parts.join('-');
  }

  String _formatBelowThousand(int value) {
    if (value < 100) return _formatBelowHundred(value);

    final hundreds = value ~/ 100;
    final rest = value % 100;
    final prefix = hundreds == 1
        ? 'cent'
        : '${_smallWords[hundreds]}-cent${rest == 0 ? 's' : ''}';
    if (rest == 0) return prefix;
    return '$prefix-${_formatBelowHundred(rest)}';
  }

  String _dropTerminalPlural(String text) {
    if (text.endsWith('cents')) return text.substring(0, text.length - 1);
    if (text.endsWith('vingts')) return text.substring(0, text.length - 1);
    return text;
  }

  String _formatBelowHundred(int value) {
    if (value < 17) return _smallWords[value];
    if (value < 20) return 'dix-${_smallWords[value - 10]}';
    if (value < 70) {
      final ten = value ~/ 10 * 10;
      final unit = value % 10;
      final tenText = _tensWords[ten]!;
      if (unit == 0) return tenText;
      if (unit == 1) return '$tenText-et-un';
      return '$tenText-${_smallWords[unit]}';
    }
    if (value < 80) {
      final rest = value - 60;
      if (rest == 11) return 'soixante-et-onze';
      return 'soixante-${_formatBelowHundred(rest)}';
    }
    if (value == 80) return 'quatre-vingts';

    return 'quatre-vingt-${_formatBelowHundred(value - 80)}';
  }

  int _parsePositive(List<String> tokens, String input) {
    var total = 0;
    var group = <String>[];
    var lastScale = 1000000000000000000;

    for (final token in tokens) {
      final scale = _scaleValues[token];
      if (scale == null) {
        group.add(token);
        continue;
      }
      if (scale >= lastScale) {
        throw FormatException('Unexpected French cardinal token.', input);
      }

      final count = group.isEmpty
          ? (scale == 1000 ? 1 : _invalid(input))
          : _parseBelowThousand(group, input);
      if (count == 0) {
        throw FormatException('Unexpected French cardinal token.', input);
      }
      if (scale != 1000 && token.endsWith('s') && count == 1) {
        throw FormatException('Unexpected French cardinal token.', input);
      }
      if (scale != 1000 && !token.endsWith('s') && count > 1) {
        throw FormatException('Unexpected French cardinal token.', input);
      }

      total += count * scale;
      group = <String>[];
      lastScale = scale;
    }

    final trailing = group.isEmpty ? 0 : _parseBelowThousand(group, input);
    return total + trailing;
  }

  int _parseBelowThousand(List<String> tokens, String input) {
    if (tokens.isEmpty) return 0;

    final centIndex = tokens.indexWhere(_isCent);
    if (centIndex < 0) return _parseBelowHundred(tokens, input);
    if (tokens.indexWhere(_isCent, centIndex + 1) >= 0) {
      throw FormatException('Unexpected French cardinal token.', input);
    }

    final left = tokens.sublist(0, centIndex);
    final right = tokens.sublist(centIndex + 1);
    final hundreds = switch (left) {
      [] => 1,
      [final token] when _digitValues[token] != null => _digitValues[token]!,
      _ => _invalid(input),
    };
    if (hundreds == 0) {
      throw FormatException('Unexpected French cardinal token.', input);
    }

    final rest = right.isEmpty ? 0 : _parseBelowHundred(right, input);
    return hundreds * 100 + rest;
  }

  int _parseBelowHundred(List<String> tokens, String input) {
    if (tokens.isEmpty) return 0;

    final key = tokens.join(' ');
    final value = _belowHundredValues[key];
    if (value == null) {
      throw FormatException('Unexpected French cardinal token.', input);
    }
    return value;
  }

  static Map<String, int> _buildBelowHundredValues() {
    final values = <String, int>{};
    for (var value = 0; value < 100; value += 1) {
      final text = _staticFormatBelowHundred(value);
      values[_normalize(text)] = value;
      if (text.contains('vingts')) {
        values[_normalize(text.replaceAll('vingts', 'vingt'))] = value;
      }
    }
    values['zero'] = 0;
    return Map.unmodifiable(values);
  }

  static String _staticFormatBelowHundred(int value) {
    if (value < 17) return _smallWords[value];
    if (value < 20) return 'dix-${_smallWords[value - 10]}';
    if (value < 70) {
      final ten = value ~/ 10 * 10;
      final unit = value % 10;
      final tenText = _tensWords[ten]!;
      if (unit == 0) return tenText;
      if (unit == 1) return '$tenText-et-un';
      return '$tenText-${_smallWords[unit]}';
    }
    if (value < 80) {
      final rest = value - 60;
      if (rest == 11) return 'soixante-et-onze';
      return 'soixante-${_staticFormatBelowHundred(rest)}';
    }
    if (value == 80) return 'quatre-vingts';
    return 'quatre-vingt-${_staticFormatBelowHundred(value - 80)}';
  }

  static String _normalize(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[‐‑‒–—―_]'), '-')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _isCent(String token) => token == 'cent' || token == 'cents';

  static bool _isZero(String token) => token == 'zéro' || token == 'zero';

  Never _invalid(String input) {
    throw FormatException('Unexpected French cardinal token.', input);
  }
}

/// Converts years to and from French cardinal numerals.
final class FrenchYearCodec extends NumeralCodec<int> {
  /// Creates a French year number codec.
  const FrenchYearCodec({this.suffix = ''});

  /// Text appended after the formatted year.
  final String suffix;

  static const _cardinal = FrenchCardinalCodec();

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
    }

    final value = _cardinal.parse(text);
    if (value < 0) {
      throw FormatException('Expected a non-negative French year.', input);
    }
    return value;
  }
}

final class _FrenchScale {
  const _FrenchScale(this.value, this.name);

  final int value;
  final String name;
}
