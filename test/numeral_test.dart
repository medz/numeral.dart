import "package:test/test.dart";
import 'package:numeral/numeral.dart';

void main() {
  group('Factory create', () {
    test('class', () {
      expect(Numeral(0), isA<Numeral>());
    });
  });

  group('get .menber', () {
    test('is double.', () {
      expect(Numeral(0).number is double, isTrue);
    });

    test('return double.', () {
      expect(Numeral(0).number, equals(0..toDouble()));
    });
  });

  group('.value', () {
    test('is String.', () {
      expect(Numeral(0).value() is String, isTrue);
    });

    test('`< 1k` return double string', () {
      expect(Numeral(100).value(), equals(100.toString()));
    });

    test('K abbr', () {
      expect(Numeral(1000).value(), equals('1K'));
    });

    test('M abbr', () {
      expect(Numeral(1000000).value(), equals('1M'));
    });

    test('B abbr', () {
      expect(Numeral(1000000000).value(), equals('1B'));
    });

    test('T abbr', () {
      expect(Numeral(1000000000000).value(), equals('1T'));
    });

    test('Negative value', () {
      expect(Numeral(-1000).value(), equals('-1K'));
    });

    test('Fraction Digits', () {
      expect(Numeral(1234).value(), equals('1.234K'));
      expect(Numeral(1234).value(fractionDigits: 2), equals('1.23K'));
    });

    test('20_000 is formatted', () {
      expect(Numeral(20000).value(fractionDigits: 0), equals('20K'));
    });

    test('200_000 is formatted', () {
      expect(Numeral(200000).value(fractionDigits: 0), equals('200K'));
    });

    test('20_000_000 is formatted', () {
      expect(Numeral(20000000).value(fractionDigits: 0), equals('20M'));
    });
  });
}
