import "package:test/test.dart";
import 'package:numeral/numeral.dart';

void main() {
  group('Constructor', () {
    test('class', () {
      expect(Numeral(0), isA<Numeral>());
    });
  });

  group('get .numeral', () {
    test('is double.', () {
      expect(Numeral(0).numeral, isA<num>());
    });

    test('return double.', () {
      expect(Numeral(0).numeral, equals(0.toDouble()));
    });
  });

  group('.format()', () {
    test('`< 1k` return double string', () {
      expect(Numeral(100).format(), equals(100.toString()));
    });

    test('K abbr', () {
      expect(Numeral(1000).format(), equals('1K'));
    });

    test('M abbr', () {
      expect(Numeral(1000000).format(), equals('1M'));
    });

    test('B abbr', () {
      expect(Numeral(1000000000).format(), equals('1B'));
    });

    test('T abbr', () {
      expect(Numeral(1000000000000).format(), equals('1T'));
    });

    test('Negative value', () {
      expect(Numeral(-1000).format(), equals('-1K'));
    });

    test('Fraction Digits', () {
      expect(Numeral(1234).format(), equals('1.234K'));
      expect(Numeral(1234).format(fractionDigits: 2), equals('1.23K'));
    });

    test('20_000 is formatted', () {
      expect(Numeral(20000).format(fractionDigits: 0), equals('20K'));
    });

    test('200_000 is formatted', () {
      expect(Numeral(200000).format(fractionDigits: 0), equals('200K'));
    });

    test('20_000_000 is formatted', () {
      expect(Numeral(20000000).format(fractionDigits: 0), equals('20M'));
    });
  });
}
