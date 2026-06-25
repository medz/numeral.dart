import 'package:numeral/numeral.dart';
import 'package:numeral/zh_hant.dart' as zh_hant;
import 'package:test/test.dart';

void main() {
  group('Traditional Chinese language path', () {
    test('exposes a Traditional Chinese language object', () {
      expect(zh_hant.zhHant, isA<NumeralLanguage>());
      expect(zh_hant.zhHant.locale, 'zh-Hant');
      expect(
        zh_hant.zhHant.compactUnits,
        same(zh_hant.traditionalChineseCompactUnits),
      );
    });

    test('formats and parses Traditional Chinese compact numbers', () {
      final codec = zh_hant.compact(maxFractionDigits: 2);

      expect(codec.format(1234567), '123.46萬');
      expect(codec.format(120000000), '1.2億');
      expect(codec.format(1200000000000), '1.2兆');
      expect(codec.parse('3.5萬'), 35000);
      expect(codec.parse('3.5万'), 35000);
      expect(codec.parse('2億'), 200000000);
      expect(codec.parse('2亿'), 200000000);
    });

    test('formats canonical cardinal numbers', () {
      final codec = zh_hant.cardinal();

      final cases = {
        0: '零',
        2: '二',
        10: '十',
        11: '十一',
        20: '二十',
        21: '二十一',
        101: '一百零一',
        110: '一百一十',
        1020: '一千零二十',
        10001: '一萬零一',
        10010: '一萬零一十',
        10021: '一萬零二十一',
        2000000: '二百萬',
        20000000: '二千萬',
        200000000: '二億',
        220000000: '二億二千萬',
        10000000000000000: '一京',
        1234567: '一百二十三萬四千五百六十七',
        123456789: '一億二千三百四十五萬六千七百八十九',
        -10021: '負一萬零二十一',
      };

      for (final entry in cases.entries) {
        expect(codec.format(entry.key), entry.value, reason: '${entry.key}');
      }
    });

    test('parses cardinal numbers and common variants', () {
      final codec = zh_hant.cardinal();

      final cases = {
        '一百萬': 1000000,
        '一百万': 1000000,
        '二百萬': 2000000,
        '兩百萬': 2000000,
        '两百万': 2000000,
        '二千萬': 20000000,
        '兩千萬': 20000000,
        '二億': 200000000,
        '兩億': 200000000,
        '一百二': 120,
        '兩百五': 250,
        '一千二': 1200,
        '一萬二': 12000,
        '一萬二千三': 12300,
        '一萬零一十': 10010,
        '一萬零十': 10010,
        '一萬零二': 10002,
        '一萬零二十一': 10021,
        '二億兩千萬': 220000000,
        '兩億兩千萬': 220000000,
        '一億二': 120000000,
        '一百二十三萬四千五百六十七': 1234567,
        '負兩百萬': -2000000,
      };

      for (final entry in cases.entries) {
        expect(codec.parse(entry.key), entry.value, reason: entry.key);
      }
    });

    test('rejects malformed cardinal numbers', () {
      final codec = zh_hant.cardinal();

      expect(codec.tryParse('not a number'), isNull);
      expect(codec.tryParse('一二'), isNull);
      expect(codec.tryParse('一百零'), isNull);
      expect(codec.tryParse('零一'), isNull);
      expect(codec.tryParse('兩十'), isNull);
      expect(codec.tryParse('一萬零兩十'), isNull);
      expect(codec.tryParse('萬'), isNull);
    });

    test('formats and parses year numbers digit by digit', () {
      final codec = zh_hant.year();
      final yearWithSuffix = zh_hant.year(suffix: '年');

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
      final codec = zh_hant.financial();

      expect(codec.format(0), '零');
      expect(codec.format(10), '壹拾');
      expect(codec.format(101), '壹佰零壹');
      expect(codec.format(10001), '壹萬零壹');
      expect(codec.format(10010), '壹萬零壹拾');
      expect(codec.format(100000), '壹拾萬');
      expect(codec.format(1000000), '壹佰萬');
      expect(codec.format(1234567), '壹佰貳拾參萬肆仟伍佰陸拾柒');

      expect(codec.parse('壹拾萬'), 100000);
      expect(codec.parse('壹佰萬'), 1000000);
      expect(codec.parse('壹佰万'), 1000000);
      expect(codec.parse('壹佰零貳'), 102);
      expect(codec.parse('壹佰零贰'), 102);
      expect(codec.parse('壹萬零壹拾'), 10010);
      expect(codec.parse('壹佰貳拾參萬肆仟伍佰陸拾柒'), 1234567);
      expect(codec.parse('壹佰贰拾叁万肆仟伍佰陆拾柒'), 1234567);
      expect(codec.tryParse('拾'), isNull);
      expect(codec.tryParse('壹佰零拾'), isNull);
      expect(codec.tryParse('壹萬零拾'), isNull);
      expect(codec.tryParse('一百萬'), isNull);
      expect(codec.tryParse('壹貳'), isNull);
      expect(codec.tryParse('萬'), isNull);
    });

    test('language object creates localized codecs', () {
      expect(
        zh_hant.zhHant.compact(maxFractionDigits: 0).format(1000000),
        '100萬',
      );
      expect(zh_hant.zhHant.cardinal().format(1000000), '一百萬');
      expect(zh_hant.zhHant.year().format(2026), '二〇二六');
      expect(zh_hant.zhHant.financial().format(1000000), '壹佰萬');
    });
  });
}
