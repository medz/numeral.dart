import 'dart:convert';

/// A codec that converts between numeric values and display strings.
abstract class NumeralCodec<T extends num> extends Codec<T, String> {
  /// Creates a numeric codec.
  const NumeralCodec();

  /// Formats [value] into a display string.
  String format(num value);

  /// Parses [input] and returns the numeric value.
  ///
  /// Throws [FormatException] when [input] cannot be parsed by this codec.
  T parse(String input);

  /// Parses [input], returning `null` instead of throwing [FormatException].
  T? tryParse(String input) {
    try {
      return parse(input);
    } on FormatException {
      return null;
    }
  }

  /// Alias for [format].
  @override
  String encode(T input) => format(input);

  /// Alias for [parse].
  @override
  T decode(String encoded) => parse(encoded);

  /// Converts numeric values into display strings.
  @override
  Converter<T, String> get encoder => _NumeralEncoder(this);

  /// Converts display strings into numeric values.
  @override
  Converter<String, T> get decoder => _NumeralDecoder(this);
}

final class _NumeralEncoder<T extends num> extends Converter<T, String> {
  const _NumeralEncoder(this.codec);

  final NumeralCodec<T> codec;

  @override
  String convert(T input) => codec.format(input);
}

final class _NumeralDecoder<T extends num> extends Converter<String, T> {
  const _NumeralDecoder(this.codec);

  final NumeralCodec<T> codec;

  @override
  T convert(String input) => codec.parse(input);
}
