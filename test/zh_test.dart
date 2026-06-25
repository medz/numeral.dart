import 'package:numeral/numeral.dart';
import 'package:numeral/zh.dart' as zh;
import 'package:test/test.dart';

void main() {
  group('Simplified Chinese language path', () {
    test('exposes a Chinese language object', () {
      expect(zh.zh, isA<NumeralLanguage>());
      expect(zh.zh.locale, 'zh');
      expect(zh.zh.compactUnits, same(zh.chineseCompactUnits));
    });

    test('formats and parses Chinese compact numbers', () {
      final codec = zh.compact(maxFractionDigits: 2);

      expect(codec.format(1234567), '123.46万');
      expect(codec.format(120000000), '1.2亿');
      expect(codec.parse('3.5万'), 35000);
    });

    test('formats canonical cardinal numbers', () {
      final codec = zh.cardinal();

      final cases = {
        0: '零',
        2: '二',
        10: '十',
        11: '十一',
        20: '二十',
        21: '二十一',
        101: '一百零一',
        110: '一百一十',
        111: '一百一十一',
        1010: '一千零一十',
        1020: '一千零二十',
        1021: '一千零二十一',
        10001: '一万零一',
        10010: '一万零一十',
        10011: '一万零一十一',
        10020: '一万零二十',
        10021: '一万零二十一',
        10100: '一万零一百',
        10101: '一万零一百零一',
        11000: '一万一千',
        12000: '一万二千',
        2000000: '二百万',
        20000000: '二千万',
        200000000: '二亿',
        220000000: '二亿二千万',
        10000000000000000: '一京',
        1234567: '一百二十三万四千五百六十七',
        123456789: '一亿二千三百四十五万六千七百八十九',
        -10021: '负一万零二十一',
      };

      for (final entry in cases.entries) {
        expect(codec.format(entry.key), entry.value, reason: '${entry.key}');
      }
    });

    test('parses cardinal numbers and common variants', () {
      final codec = zh.cardinal();

      final cases = {
        '一百万': 1000000,
        '二百万': 2000000,
        '两百万': 2000000,
        '二千万': 20000000,
        '两千万': 20000000,
        '二亿': 200000000,
        '两亿': 200000000,
        '一百二': 120,
        '两百五': 250,
        '一千二': 1200,
        '一千二百三': 1230,
        '一千零一十': 1010,
        '一千零十': 1010,
        '一千零二十': 1020,
        '一千零二十一': 1021,
        '一万二': 12000,
        '一万二千三': 12300,
        '一万二千三百四': 12340,
        '一万零一十': 10010,
        '一万零十': 10010,
        '一万零二': 10002,
        '一万零二十': 10020,
        '一万零二十一': 10021,
        '一万二千': 12000,
        '一万两千': 12000,
        '两万二千': 22000,
        '一亿二': 120000000,
        '二亿两千万': 220000000,
        '两亿两千万': 220000000,
        '一百二十三万四千五百六十七': 1234567,
        '负两百万': -2000000,
      };

      for (final entry in cases.entries) {
        expect(codec.parse(entry.key), entry.value, reason: entry.key);
      }
    });

    test('rejects malformed cardinal numbers', () {
      final codec = zh.cardinal();

      expect(codec.tryParse('not a number'), isNull);
      expect(codec.tryParse('一二'), isNull);
      expect(codec.tryParse('一百零'), isNull);
      expect(codec.tryParse('零一'), isNull);
      expect(codec.tryParse('两十'), isNull);
      expect(codec.tryParse('两十二'), isNull);
      expect(codec.tryParse('一万零两十'), isNull);
      expect(codec.tryParse('万'), isNull);
    });

    test('rejects cardinal values beyond supported section units', () {
      final codec = zh.cardinal();

      expect(
        () => codec.format(1e20),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('formats and parses year numbers digit by digit', () {
      final codec = zh.year();
      final yearWithSuffix = zh.year(suffix: '年');

      expect(codec.format(2025), '二〇二五');
      expect(codec.format(2026), '二〇二六');
      expect(yearWithSuffix.format(2026), '二〇二六年');
      expect(codec.parse('二〇二六'), 2026);
      expect(codec.parse('二零二六年'), 2026);
      expect(yearWithSuffix.parse('二〇二六年'), 2026);
      expect(yearWithSuffix.tryParse('二〇二六'), isNull);
      expect(codec.tryParse('二千零二十六'), isNull);
      expect(() => codec.format(1e20), throwsA(isA<ArgumentError>()));
    });

    test('formats and parses financial numerals', () {
      final codec = zh.financial();

      expect(codec.format(0), '零');
      expect(codec.format(10), '壹拾');
      expect(codec.format(101), '壹佰零壹');
      expect(codec.format(10001), '壹万零壹');
      expect(codec.format(10010), '壹万零壹拾');
      expect(codec.format(100000), '壹拾万');
      expect(codec.format(1000000), '壹佰万');
      expect(codec.format(10000000000000000), '壹京');
      expect(codec.format(1234567), '壹佰贰拾叁万肆仟伍佰陆拾柒');

      expect(codec.parse('壹拾万'), 100000);
      expect(codec.parse('壹佰万'), 1000000);
      expect(codec.parse('壹佰零贰'), 102);
      expect(codec.parse('壹万零壹拾'), 10010);
      expect(codec.parse('壹佰贰拾叁万肆仟伍佰陆拾柒'), 1234567);
      expect(codec.tryParse('拾'), isNull);
      expect(codec.tryParse('佰'), isNull);
      expect(codec.tryParse('仟'), isNull);
      expect(codec.tryParse('拾万'), isNull);
      expect(codec.tryParse('佰万'), isNull);
      expect(codec.tryParse('壹佰零拾'), isNull);
      expect(codec.tryParse('壹万零拾'), isNull);
      expect(codec.tryParse('一百万'), isNull);
      expect(codec.tryParse('壹贰'), isNull);
      expect(codec.tryParse('壹佰贰'), isNull);
      expect(codec.tryParse('壹仟贰佰叁'), isNull);
      expect(codec.tryParse('壹佰零'), isNull);
      expect(codec.tryParse('零壹'), isNull);
      expect(codec.tryParse('万'), isNull);
    });

    test('rejects financial values beyond supported section units', () {
      final codec = zh.financial();

      expect(
        () => codec.format(1e20),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => zh.rmb().format(1e20),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('formats and parses RMB uppercase amounts', () {
      final codec = zh.rmb();

      expect(codec.format(0), '人民币零元整');
      expect(codec.format(100000), '人民币壹拾万元整');
      expect(codec.format(1000000), '人民币壹佰万元整');
      expect(
        codec.format(1234567.89),
        '人民币壹佰贰拾叁万肆仟伍佰陆拾柒元捌角玖分',
      );
      expect(codec.format(100.01), '人民币壹佰元零壹分');
      expect(codec.format(0.1), '人民币壹角');

      expect(codec.parse('人民币壹拾万元整'), 100000);
      expect(codec.parse('人民币壹佰万元整'), 1000000);
      expect(
        codec.parse('人民币壹佰贰拾叁万肆仟伍佰陆拾柒元捌角玖分'),
        1234567.89,
      );
      expect(codec.parse('人民币壹佰元零壹分'), 100.01);
      expect(codec.parse('人民币壹角'), 0.1);
      expect(codec.tryParse('人民币拾万元整'), isNull);
      expect(codec.tryParse('人民币佰万元整'), isNull);
      expect(codec.tryParse('人民币壹万零拾元整'), isNull);
      expect(codec.tryParse('人民币整'), isNull);
      expect(codec.tryParse('人民币元整'), isNull);
      expect(codec.tryParse('人民币壹佰元零零'), isNull);
    });

    test('supports RMB uppercase amount options', () {
      final noPrefix = zh.rmb(prefix: '');
      final jiaoExact = zh.rmb(writeWholeSuffixForJiao: true);

      expect(noPrefix.format(100), '壹佰元整');
      expect(jiaoExact.format(0.1), '人民币壹角整');
    });

    test('language object creates localized codecs', () {
      expect(zh.zh.cardinal().format(1000000), '一百万');
      expect(zh.zh.year().format(2026), '二〇二六');
      expect(zh.zh.financial().format(1000000), '壹佰万');
      expect(zh.zh.rmb().format(1000000), '人民币壹佰万元整');
    });
  });
}
