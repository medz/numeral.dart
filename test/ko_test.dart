import 'package:numeral/ko.dart' as ko;
import 'package:numeral/numeral.dart';
import 'package:test/test.dart';

void main() {
  group('Korean language path', () {
    test('exposes a Korean language object', () {
      expect(ko.ko, isA<NumeralLanguage>());
      expect(ko.ko.locale, 'ko');
      expect(ko.ko.compactUnits, same(ko.koreanCompactUnits));
    });

    test('formats and parses Korean compact numbers', () {
      final codec = ko.compact(maxFractionDigits: 2);

      expect(codec.format(1000), '1천');
      expect(codec.format(1100), '1.1천');
      expect(codec.format(12345), '1.23만');
      expect(codec.format(1000000), '100만');
      expect(codec.format(120000000), '1.2억');
      expect(codec.format(1200000000000), '1.2조');
      expect(codec.parse('1천'), 1000);
      expect(codec.parse('1.1천'), 1100);
      expect(codec.parse('1千'), 1000);
      expect(codec.parse('1.5만'), 15000);
      expect(codec.parse('2억'), 200000000);
      expect(codec.parse('3萬'), 30000);
      expect(codec.parse('1兆'), 1000000000000);
    });

    test('formats canonical Sino-Korean cardinal numbers', () {
      final codec = ko.cardinal();

      final cases = {
        0: '영',
        1: '일',
        10: '십',
        11: '십일',
        20: '이십',
        21: '이십일',
        100: '백',
        101: '백일',
        110: '백십',
        111: '백십일',
        1000: '천',
        1001: '천일',
        1010: '천십',
        1100: '천백',
        1111: '천백십일',
        10000: '만',
        10001: '만일',
        10010: '만십',
        10100: '만백',
        11000: '만천',
        100000: '십만',
        1000000: '백만',
        10000000: '천만',
        100000000: '일억',
        100010000: '일억일만',
        200000000: '이억',
        1000000000000: '일조',
        10000000000000000: '일경',
        123456789: '일억이천삼백사십오만육천칠백팔십구',
        -10001: '마이너스만일',
      };

      for (final entry in cases.entries) {
        expect(codec.format(entry.key), entry.value, reason: '${entry.key}');
      }
    });

    test('parses cardinal numbers and common variants', () {
      final codec = ko.cardinal();

      final cases = {
        '영': 0,
        '공': 0,
        '령': 0,
        '십': 10,
        '일십': 10,
        '백': 100,
        '일백': 100,
        '천': 1000,
        '일천': 1000,
        '만': 10000,
        '일만': 10000,
        '만일': 10001,
        '일만영일': 10001,
        '만십': 10010,
        '일만영십': 10010,
        '백만': 1000000,
        '일백만': 1000000,
        '천만': 10000000,
        '일천만': 10000000,
        '일억': 100000000,
        '일억일만': 100010000,
        '일억 이천만': 120000000,
        '이억이천만': 220000000,
        '일억이천삼백사십오만육천칠백팔십구': 123456789,
        '壹億貳仟參佰肆拾伍萬六千七百八十九': 123456789,
        '마이너스백만': -1000000,
        '-백만': -1000000,
      };

      for (final entry in cases.entries) {
        expect(codec.parse(entry.key), entry.value, reason: entry.key);
      }
    });

    test('rejects malformed cardinal numbers', () {
      final codec = ko.cardinal();

      expect(codec.tryParse('not a number'), isNull);
      expect(codec.tryParse('일이'), isNull);
      expect(codec.tryParse('영일'), isNull);
      expect(codec.tryParse('십영일'), isNull);
      expect(codec.tryParse('백영십'), isNull);
      expect(codec.tryParse('천영백'), isNull);
      expect(codec.tryParse('일만영천'), isNull);
      expect(codec.tryParse('만영'), isNull);
      expect(codec.tryParse('만만'), isNull);
      expect(codec.tryParse('억만'), isNull);
      expect(codec.tryParse('일억만'), isNull);
      expect(codec.tryParse('백백'), isNull);
    });

    test('rejects cardinal values beyond supported section units', () {
      final codec = ko.cardinal();

      expect(
        () => codec.format(1e20),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('formats and parses year numbers with Sino-Korean readings', () {
      final codec = ko.year();
      final yearWithSuffix = ko.year(suffix: '년');

      expect(codec.format(2025), '이천이십오');
      expect(codec.format(2026), '이천이십육');
      expect(yearWithSuffix.format(2026), '이천이십육년');
      expect(codec.parse('이천이십육'), 2026);
      expect(codec.parse('이천이십육년'), 2026);
      expect(yearWithSuffix.parse('이천이십육년'), 2026);
      expect(yearWithSuffix.tryParse('이천이십육'), isNull);
      expect(codec.tryParse('마이너스일년'), isNull);
      expect(
        () => codec.format(double.maxFinite),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('language object creates localized codecs', () {
      expect(ko.ko.compact(maxFractionDigits: 0).format(1000000), '100만');
      expect(ko.ko.cardinal().format(1000000), '백만');
      expect(ko.ko.year().format(2026), '이천이십육');
    });
  });
}
