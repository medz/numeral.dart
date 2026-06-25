import 'package:numeral/es.dart' as es;
import 'package:numeral/numeral.dart';
import 'package:test/test.dart';

void main() {
  group('Spanish language path', () {
    test('exposes a Spanish language object', () {
      expect(es.es, isA<NumeralLanguage>());
      expect(es.es.locale, 'es');
      expect(es.es.compactUnits, same(es.spanishCompactUnits));
    });

    test('formats and parses Spanish compact numbers', () {
      final codec = es.compact(maxFractionDigits: 2);

      expect(codec.format(12345), '12,35 mil');
      expect(codec.format(1000000), '1 M');
      expect(codec.format(1500000), '1,5 M');
      expect(codec.format(1000000000), '1000 M');
      expect(codec.format(1000000000000), '1 B');
      expect(codec.parse('12,35 mil'), 12350);
      expect(codec.parse('1,5 M'), 1500000);
      expect(codec.parse('2 millones'), 2000000);
      expect(codec.parse('1 B'), 1000000000000);
      expect(codec.parse('3 mil'), 3000);
    });

    test('formats canonical Spanish cardinal numbers', () {
      final codec = es.cardinal();

      final cases = {
        0: 'cero',
        1: 'uno',
        16: 'dieciséis',
        21: 'veintiuno',
        22: 'veintidós',
        26: 'veintiséis',
        31: 'treinta y uno',
        100: 'cien',
        101: 'ciento uno',
        115: 'ciento quince',
        121: 'ciento veintiuno',
        200: 'doscientos',
        500: 'quinientos',
        999: 'novecientos noventa y nueve',
        1000: 'mil',
        1001: 'mil uno',
        21000: 'veintiún mil',
        101000: 'ciento un mil',
        1000000: 'un millón',
        2000000: 'dos millones',
        21000000: 'veintiún millones',
        1000000000: 'mil millones',
        1200000000: 'mil doscientos millones',
        1000000000000: 'un billón',
        2000000000000: 'dos billones',
        1234567890:
            'mil doscientos treinta y cuatro millones quinientos sesenta y siete mil ochocientos noventa',
        -1000000: 'menos un millón',
      };

      for (final entry in cases.entries) {
        expect(codec.format(entry.key), entry.value, reason: '${entry.key}');
      }
    });

    test('parses cardinal numbers and common variants', () {
      final codec = es.cardinal();

      final cases = {
        'cero': 0,
        'dieciseis': 16,
        'dieciséis': 16,
        'veintidos': 22,
        'veintidós': 22,
        'treinta y un': 31,
        'treinta y uno': 31,
        'cien': 100,
        'ciento uno': 101,
        'doscientas treinta y una': 231,
        'mil': 1000,
        'veintiún mil': 21000,
        'veintiun mil': 21000,
        'un millón': 1000000,
        'uno millon': 1000000,
        'dos millones': 2000000,
        'mil millones': 1000000000,
        'un billón': 1000000000000,
        'dos billones': 2000000000000,
        'mil doscientos treinta y cuatro millones quinientos sesenta y siete mil ochocientos noventa':
            1234567890,
        'menos un millón': -1000000,
      };

      for (final entry in cases.entries) {
        expect(codec.parse(entry.key), entry.value, reason: entry.key);
      }
    });

    test('rejects malformed cardinal numbers', () {
      final codec = es.cardinal();

      expect(codec.tryParse('not a number'), isNull);
      expect(codec.tryParse('cien uno'), isNull);
      expect(codec.tryParse('ciento'), isNull);
      expect(codec.tryParse('uno dos'), isNull);
      expect(codec.tryParse('un millones'), isNull);
      expect(codec.tryParse('dos millón'), isNull);
      expect(codec.tryParse('millón'), isNull);
      expect(codec.tryParse('billón'), isNull);
      expect(codec.tryParse('menos millón'), isNull);
      expect(codec.tryParse('millones millones'), isNull);
      expect(codec.tryParse('cero uno'), isNull);
      expect(codec.tryParse('mil cero'), isNull);
    });

    test('rejects cardinal values beyond supported range', () {
      final codec = es.cardinal();

      expect(
        () => codec.format(1e20),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('language object creates localized codecs', () {
      expect(
        es.es.compact(maxFractionDigits: 1).format(1500000),
        '1,5 M',
      );
      expect(es.es.cardinal().format(1000000), 'un millón');
      expect(es.es.cardinal().parse('mil millones'), 1000000000);
    });
  });
}
