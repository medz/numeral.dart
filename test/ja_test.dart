import 'package:numeral/ja.dart' as ja;
import 'package:numeral/numeral.dart';
import 'package:test/test.dart';

void main() {
  group('Japanese language path', () {
    test('exposes a Japanese language object', () {
      expect(ja.ja, isA<NumeralLanguage>());
      expect(ja.ja.locale, 'ja');
      expect(ja.ja.compactUnits, same(ja.japaneseCompactUnits));
    });

    test('formats and parses Japanese compact numbers', () {
      final codec = ja.compact(maxFractionDigits: 2);

      expect(codec.format(1234567), '123.46万');
      expect(codec.format(120000000), '1.2億');
      expect(codec.format(1200000000000), '1.2兆');
      expect(codec.parse('3.5万'), 35000);
      expect(codec.parse('2億'), 200000000);
      expect(codec.parse('1萬'), 10000);
    });

    test('formats canonical cardinal numbers', () {
      final codec = ja.cardinal();

      final cases = {
        0: '零',
        1: '一',
        10: '十',
        11: '十一',
        20: '二十',
        21: '二十一',
        100: '百',
        101: '百一',
        110: '百十',
        111: '百十一',
        1000: '千',
        1001: '千一',
        1010: '千十',
        1100: '千百',
        1111: '千百十一',
        10000: '一万',
        10001: '一万一',
        10010: '一万十',
        10100: '一万百',
        11000: '一万千',
        100000: '十万',
        1000000: '百万',
        2000000: '二百万',
        10000000: '一千万',
        15000000: '一千五百万',
        100000000: '一億',
        123456789: '一億二千三百四十五万六千七百八十九',
        10000000000000000: '一京',
        -10001: '負一万一',
      };

      for (final entry in cases.entries) {
        expect(codec.format(entry.key), entry.value, reason: '${entry.key}');
      }
    });

    test('parses cardinal numbers and common variants', () {
      final codec = ja.cardinal();

      final cases = {
        '十': 10,
        '百': 100,
        '千': 1000,
        '万': 10000,
        '一万一': 10001,
        '一万〇一': 10001,
        '一万零十': 10010,
        '一万〇二十': 10020,
        '百〇一': 101,
        '千〇一': 1001,
        '百万': 1000000,
        '二百万': 2000000,
        '千万': 10000000,
        '一千万': 10000000,
        '千五百万': 15000000,
        '一千五百万': 15000000,
        '一億二千万': 120000000,
        '二億二千万': 220000000,
        '一万二千三百四': 12304,
        '一万二千三百四十': 12340,
        '壱万弐千参百四十五': 12345,
        '壱佰壱': 101,
        '負二百万': -2000000,
      };

      for (final entry in cases.entries) {
        expect(codec.parse(entry.key), entry.value, reason: entry.key);
      }
    });

    test('rejects malformed cardinal numbers', () {
      final codec = ja.cardinal();

      expect(codec.tryParse('not a number'), isNull);
      expect(codec.tryParse('一二'), isNull);
      expect(codec.tryParse('零一'), isNull);
      expect(codec.tryParse('一〇一'), isNull);
      expect(codec.tryParse('十〇一'), isNull);
      expect(codec.tryParse('一万零'), isNull);
      expect(codec.tryParse('万万'), isNull);
      expect(codec.tryParse('億万'), isNull);
      expect(codec.tryParse('一億万'), isNull);
      expect(codec.tryParse('一百百'), isNull);
    });

    test('rejects cardinal values beyond supported section units', () {
      final codec = ja.cardinal();

      expect(
        () => codec.format(1e20),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('formats and parses year numbers digit by digit', () {
      final codec = ja.year();
      final yearWithSuffix = ja.year(suffix: '年');

      expect(codec.format(2025), '二〇二五');
      expect(codec.format(2026), '二〇二六');
      expect(yearWithSuffix.format(2026), '二〇二六年');
      expect(codec.parse('二〇二六'), 2026);
      expect(codec.parse('二零二六年'), 2026);
      expect(yearWithSuffix.parse('二〇二六年'), 2026);
      expect(yearWithSuffix.tryParse('二〇二六'), isNull);
      expect(codec.tryParse('二千二十六'), isNull);
      expect(
        () => codec.format(double.maxFinite),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('language object creates localized codecs', () {
      expect(ja.ja.compact(maxFractionDigits: 0).format(1000000), '100万');
      expect(ja.ja.cardinal().format(1000000), '百万');
      expect(ja.ja.year().format(2026), '二〇二六');
    });
  });
}
