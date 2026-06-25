import 'package:numeral/numeral.dart';
import 'package:numeral/en.dart' as en;
import 'package:numeral/zh.dart' as zh;
import 'package:test/test.dart';

void main() {
  group('codec protocol', () {
    test('supports encode/decode and converters', () {
      final bytes = BytesCodec.binary(maxFractionDigits: 1);
      final percent = PercentCodec(maxFractionDigits: 1);

      expect(bytes.encode(1536), '1.5 KiB');
      expect(bytes.decode('1.5 KiB'), 1536);
      expect(bytes.encoder.convert(1536), '1.5 KiB');
      expect(bytes.decoder.convert('1.5 KiB'), 1536);

      expect(percent.encode(0.125), '12.5%');
      expect(percent.decode('12.5%'), 0.125);
    });
  });

  group('decimal', () {
    test('formats grouped decimal values', () {
      final codec = DecimalCodec(
        minFractionDigits: 2,
        maxFractionDigits: 2,
      );

      expect(codec.format(1234567.8), '1,234,567.80');
      expect(codec.format(-1234.567), '-1,234.57');
      expect(codec.format(double.infinity), '∞');
      expect(codec.format(double.negativeInfinity), '-∞');
      expect(codec.format(double.nan), 'NaN');
    });

    test('can truncate instead of rounding', () {
      final codec = DecimalCodec(
        maxFractionDigits: 2,
        rounding: Rounding.truncate,
      );

      expect(codec.format(1234.569), '1,234.56');
      expect(codec.format(-1234.569), '-1,234.56');
    });

    test('parses grouped values directly to num', () {
      final codec = DecimalCodec();

      expect(codec.parse('1,234.5'), 1234.5);
      expect(codec.parse('-1,234'), -1234);
      expect(codec.tryParse('not a number'), isNull);
    });
  });

  group('compact', () {
    test('formats western compact numbers', () {
      final codec = CompactCodec(
        unitSet: en.englishCompactUnits,
        maxFractionDigits: 1,
      );

      expect(codec.format(1234), '1.2K');
      expect(codec.format(1234567), '1.2M');
      expect(codec.format(-1234567), '-1.2M');
    });

    test('moves rounded overflow to the next unit', () {
      final codec = CompactCodec(
        unitSet: en.englishCompactUnits,
        maxFractionDigits: 0,
      );

      expect(codec.format(999999), '1M');
      expect(codec.format(999999999), '1B');
    });

    test('supports Chinese compact units', () {
      final codec = CompactCodec(
        unitSet: zh.chineseCompactUnits,
        maxFractionDigits: 2,
      );

      expect(codec.format(1234567), '123.46万');
      expect(codec.format(120000000), '1.2亿');
    });

    test('parses compact suffixes directly to num', () {
      final codec = CompactCodec(unitSet: en.englishCompactUnits);
      final zhCompact = CompactCodec(
        unitSet: zh.chineseCompactUnits,
      );

      expect(codec.parse('1.2K'), 1200);
      expect(codec.parse('3 million'), 3000000);
      expect(codec.parse('-1.5B'), -1500000000);
      expect(zhCompact.parse('3.5万'), 35000);
      expect(codec.tryParse('abc'), isNull);
    });
  });

  group('percent', () {
    test('formats ratios as percentages', () {
      final codec = PercentCodec(maxFractionDigits: 1);

      expect(codec.format(0.1234), '12.3%');
      expect(codec.format(1), '100%');
    });

    test('parses percentages directly to double', () {
      final codec = PercentCodec();

      expect(codec.parse('12.5%'), 0.125);
      expect(codec.parse('-50%'), -0.5);
      expect(codec.tryParse('12.5'), isNull);
    });
  });

  group('bytes', () {
    test('formats decimal byte sizes', () {
      final codec = BytesCodec(maxFractionDigits: 1);

      expect(codec.format(999), '999 B');
      expect(codec.format(1000), '1 KB');
      expect(codec.format(1500), '1.5 KB');
      expect(codec.format(2500000), '2.5 MB');
    });

    test('formats binary byte sizes', () {
      final codec = BytesCodec.binary(maxFractionDigits: 1);

      expect(codec.format(1024), '1 KiB');
      expect(codec.format(1536), '1.5 KiB');
      expect(codec.format(1048576), '1 MiB');
    });

    test('parses byte sizes directly to int', () {
      final decimal = BytesCodec();
      final binary = BytesCodec.binary();

      expect(decimal.parse('1 KB'), 1000);
      expect(decimal.parse('1.5 MB'), 1500000);
      expect(binary.parse('1.5 KiB'), 1536);
      expect(binary.tryParse('0.1 B'), isNull);
    });
  });

  group('currency', () {
    test('formats and parses display currency values', () {
      final usd = CurrencyCodec(r'$');
      final cny = CurrencyCodec(
        '元',
        symbolOnRight: true,
        spaceBetweenSymbolAndNumber: true,
        maxFractionDigits: 0,
        minFractionDigits: 0,
      );

      expect(usd.format(1234.5), r'$1,234.50');
      expect(usd.format(-1234.5), r'-$1,234.50');
      expect(usd.parse(r'$1,234.50'), 1234.5);
      expect(usd.parse(r'-$1,234.50'), -1234.5);
      expect(cny.format(99), '99 元');
      expect(cny.parse('99 元'), 99);
    });
  });

  group('language packs', () {
    test('provides compact codecs through built-in language paths', () {
      expect(en.compact(maxFractionDigits: 1).format(12345), '12.3K');
      expect(zh.compact(maxFractionDigits: 2).format(1234567), '123.46万');
    });

    test('formats and parses Simplified Chinese cardinal numbers', () {
      final codec = zh.cardinal();

      expect(codec.format(0), '零');
      expect(codec.format(10), '十');
      expect(codec.format(11), '十一');
      expect(codec.format(101), '一百零一');
      expect(codec.format(10001), '一万零一');
      expect(codec.format(1000000), '一百万');
      expect(codec.format(1234567), '一百二十三万四千五百六十七');

      expect(codec.parse('一百万'), 1000000);
      expect(codec.parse('一百二十三万四千五百六十七'), 1234567);
      expect(codec.tryParse('not a number'), isNull);
    });
  });
}
