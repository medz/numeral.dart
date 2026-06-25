import 'package:numeral/codec.dart';
import 'package:numeral/extension.dart';
import 'package:numeral/zh.dart' as zh;
import 'package:test/test.dart';

void main() {
  group('num extensions', () {
    test('format values with reusable codecs', () {
      expect(1000000.formatWith(zh.cardinal()), '一百万');
      expect(1234.5.formatWith(DecimalCodec(maxFractionDigits: 1)), '1,234.5');
    });

    test('format common number styles directly', () {
      expect(1234.5.decimal(maxFractionDigits: 1), '1,234.5');
      expect(12345.compact(maxFractionDigits: 1), '12.3K');
      expect(
        1234567.compact(
          unitSet: zh.chineseCompactUnits,
          maxFractionDigits: 2,
        ),
        '123.46万',
      );
      expect(0.1234.percent(maxFractionDigits: 2), '12.34%');
      expect(1500.bytes(maxFractionDigits: 1), '1.5 KB');
      expect(1536.bytes(binary: true, maxFractionDigits: 1), '1.5 KiB');
    });

    test('format display currency values directly', () {
      expect(1234.5.currency(r'$'), r'$1,234.50');
      expect(
        1000000.currency(
          '¥',
          style: zh.compact(maxFractionDigits: 0),
        ),
        '¥100万',
      );
    });
  });
}
