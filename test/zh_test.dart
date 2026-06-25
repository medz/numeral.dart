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

    test('formats and parses cardinal numbers', () {
      final codec = zh.cardinal();

      expect(codec.format(0), '零');
      expect(codec.format(10), '十');
      expect(codec.format(11), '十一');
      expect(codec.format(101), '一百零一');
      expect(codec.format(1010), '一千零一十');
      expect(codec.format(10001), '一万零一');
      expect(codec.format(10010), '一万零一十');
      expect(codec.format(10020), '一万零二十');
      expect(codec.format(1000000), '一百万');
      expect(codec.format(1234567), '一百二十三万四千五百六十七');

      expect(codec.parse('一百万'), 1000000);
      expect(codec.parse('一千零一十'), 1010);
      expect(codec.parse('一千零十'), 1010);
      expect(codec.parse('一万零一十'), 10010);
      expect(codec.parse('一万零十'), 10010);
      expect(codec.parse('一万零二十'), 10020);
      expect(codec.parse('一百二十三万四千五百六十七'), 1234567);
      expect(codec.tryParse('not a number'), isNull);
      expect(codec.tryParse('一二'), isNull);
      expect(codec.tryParse('一百零'), isNull);
      expect(codec.tryParse('零一'), isNull);
      expect(codec.tryParse('万'), isNull);
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
    });

    test('formats and parses financial numerals', () {
      final codec = zh.financial();

      expect(codec.format(0), '零');
      expect(codec.format(10), '壹拾');
      expect(codec.format(101), '壹佰零壹');
      expect(codec.format(10001), '壹万零壹');
      expect(codec.format(10010), '壹万零壹拾');
      expect(codec.format(1000000), '壹佰万');
      expect(codec.format(1234567), '壹佰贰拾叁万肆仟伍佰陆拾柒');

      expect(codec.parse('壹佰万'), 1000000);
      expect(codec.parse('壹万零壹拾'), 10010);
      expect(codec.parse('壹佰贰拾叁万肆仟伍佰陆拾柒'), 1234567);
      expect(codec.tryParse('一百万'), isNull);
      expect(codec.tryParse('壹贰'), isNull);
      expect(codec.tryParse('壹佰零'), isNull);
      expect(codec.tryParse('零壹'), isNull);
      expect(codec.tryParse('万'), isNull);
    });

    test('formats and parses RMB uppercase amounts', () {
      final codec = zh.rmb();

      expect(codec.format(0), '人民币零元整');
      expect(codec.format(1000000), '人民币壹佰万元整');
      expect(
        codec.format(1234567.89),
        '人民币壹佰贰拾叁万肆仟伍佰陆拾柒元捌角玖分',
      );
      expect(codec.format(100.01), '人民币壹佰元零壹分');
      expect(codec.format(0.1), '人民币壹角');

      expect(codec.parse('人民币壹佰万元整'), 1000000);
      expect(
        codec.parse('人民币壹佰贰拾叁万肆仟伍佰陆拾柒元捌角玖分'),
        1234567.89,
      );
      expect(codec.parse('人民币壹佰元零壹分'), 100.01);
      expect(codec.parse('人民币壹角'), 0.1);
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
