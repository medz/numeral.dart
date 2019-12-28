import "package:test/test.dart";
import 'package:numeral/numeral.dart';

void main() {
  group('Factory create', () {
    test('Failed assertion.', () {
      try {
        Numeral(null);
      } catch (_) {
        expect(true, isTrue);
      }
    });

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
  });
}
