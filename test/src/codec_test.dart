import 'package:numeral/src/codec.dart';
import 'package:test/test.dart';

void main() {
  group('NumeralCodec', () {
    test('provides encode/decode aliases and converters', () {
      const codec = _TaggedCodec();

      expect(codec.format(12.5), 'n:12.5');
      expect(codec.parse('n:12.5'), 12.5);
      expect(codec.encode(12.5), 'n:12.5');
      expect(codec.decode('n:12.5'), 12.5);
      expect(codec.encoder.convert(12.5), 'n:12.5');
      expect(codec.decoder.convert('n:12.5'), 12.5);
    });

    test('tryParse returns null for format failures', () {
      const codec = _TaggedCodec();

      expect(codec.tryParse('bad'), isNull);
    });
  });
}

final class _TaggedCodec extends NumeralCodec<num> {
  const _TaggedCodec();

  @override
  String format(num value) => 'n:$value';

  @override
  num parse(String input) {
    if (!input.startsWith('n:')) {
      throw FormatException('Expected tagged number.', input);
    }
    return num.parse(input.substring(2));
  }
}
