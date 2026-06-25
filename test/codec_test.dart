import 'package:numeral/codec.dart';
import 'package:numeral/numeral.dart';
import 'package:test/test.dart';

void main() {
  group('public codec barrel', () {
    test('exports concrete codecs', () {
      final units = NumeralUnitSet([
        NumeralUnit(1, ''),
        NumeralUnit(1000, 'K'),
      ]);

      expect(DecimalCodec(maxFractionDigits: 1).format(1234.5), '1,234.5');
      expect(CompactCodec(unitSet: units).format(1200), '1.2K');
      expect(PercentCodec().format(0.12), '12%');
      expect(BytesCodec.binary().format(1024), '1 KiB');
      expect(CurrencyCodec(r'$').format(1), r'$1.00');
    });
  });
}
