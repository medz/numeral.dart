import 'package:numeral/fr.dart' as fr;
import 'package:numeral/numeral.dart';
import 'package:test/test.dart';

void main() {
  group('French language path', () {
    test('exposes a French language object', () {
      expect(fr.fr, isA<NumeralLanguage>());
      expect(fr.fr.locale, 'fr');
      expect(fr.fr.compactUnits, same(fr.frenchCompactUnits));
    });

    test('formats and parses French compact numbers', () {
      final codec = fr.compact(maxFractionDigits: 1);

      expect(codec.format(1234), '1,2 k');
      expect(codec.format(1500000), '1,5 M');
      expect(codec.format(1200000000), '1,2 Md');
      expect(codec.format(1200000000000), '1,2 Bn');
      expect(codec.parse('1,5 k'), 1500);
      expect(codec.parse('1,5K'), 1500);
      expect(codec.parse('2 millions'), 2000000);
      expect(codec.parse('3 milliards'), 3000000000);
      expect(codec.parse('1 billion'), 1000000000000);
    });

    test('formats canonical cardinal numbers', () {
      final codec = fr.cardinal();

      final cases = {
        0: 'zéro',
        1: 'un',
        10: 'dix',
        17: 'dix-sept',
        20: 'vingt',
        21: 'vingt-et-un',
        22: 'vingt-deux',
        69: 'soixante-neuf',
        70: 'soixante-dix',
        71: 'soixante-et-onze',
        72: 'soixante-douze',
        80: 'quatre-vingts',
        81: 'quatre-vingt-un',
        91: 'quatre-vingt-onze',
        99: 'quatre-vingt-dix-neuf',
        100: 'cent',
        101: 'cent-un',
        200: 'deux-cents',
        201: 'deux-cent-un',
        999: 'neuf-cent-quatre-vingt-dix-neuf',
        1000: 'mille',
        1001: 'mille-un',
        2000: 'deux-mille',
        1000000: 'un-million',
        2000000: 'deux-millions',
        1000000000: 'un-milliard',
        2000000000: 'deux-milliards',
        1000000000000: 'un-billion',
        123456789:
            'cent-vingt-trois-millions-quatre-cent-cinquante-six-mille-sept-cent-quatre-vingt-neuf',
        -2026: 'moins-deux-mille-vingt-six',
      };

      for (final entry in cases.entries) {
        expect(codec.format(entry.key), entry.value, reason: '${entry.key}');
      }
    });

    test('parses cardinal numbers and common variants', () {
      final codec = fr.cardinal();

      final cases = {
        'zero': 0,
        'vingt et un': 21,
        'vingt-et-un': 21,
        'soixante et onze': 71,
        'soixante-douze': 72,
        'quatre vingt': 80,
        'quatre-vingts': 80,
        'quatre vingt onze': 91,
        'deux cents': 200,
        'deux-cent-un': 201,
        'mille un': 1001,
        'deux mille': 2000,
        'un million': 1000000,
        'deux millions': 2000000,
        'un milliard deux millions': 1002000000,
        'un-billion-deux-milliards-trois-millions-quatre-mille-cinq':
            1002003004005,
        'moins deux mille vingt six': -2026,
      };

      for (final entry in cases.entries) {
        expect(codec.parse(entry.key), entry.value, reason: entry.key);
      }
    });

    test('rejects malformed cardinal numbers', () {
      final codec = fr.cardinal();

      expect(codec.tryParse('not a number'), isNull);
      expect(codec.tryParse('un deux'), isNull);
      expect(codec.tryParse('vingt et deux'), isNull);
      expect(codec.tryParse('quatre-vingts-un'), isNull);
      expect(codec.tryParse('deux-million'), isNull);
      expect(codec.tryParse('un-millions'), isNull);
      expect(codec.tryParse('million'), isNull);
      expect(codec.tryParse('mille-mille'), isNull);
      expect(codec.tryParse('zéro-un'), isNull);
    });

    test('rejects cardinal values beyond supported range', () {
      final codec = fr.cardinal();

      expect(
        () => codec.format(1e20),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('formats and parses year numbers', () {
      final codec = fr.year();
      final yearWithSuffix = fr.year(suffix: ' ap. J.-C.');

      expect(codec.format(2025), 'deux-mille-vingt-cinq');
      expect(codec.format(2026), 'deux-mille-vingt-six');
      expect(yearWithSuffix.format(2026), 'deux-mille-vingt-six ap. J.-C.');
      expect(codec.parse('deux mille vingt six'), 2026);
      expect(codec.parse('deux-mille-vingt-six'), 2026);
      expect(yearWithSuffix.parse('deux-mille-vingt-six ap. J.-C.'), 2026);
      expect(yearWithSuffix.tryParse('deux-mille-vingt-six'), isNull);
      expect(codec.tryParse('moins-un'), isNull);
      expect(
          () => codec.format(double.maxFinite), throwsA(isA<ArgumentError>()));
    });

    test('language object creates localized codecs', () {
      expect(fr.fr.compact(maxFractionDigits: 0).format(1000000), '1 M');
      expect(fr.fr.cardinal().format(1000000), 'un-million');
      expect(fr.fr.year().format(2026), 'deux-mille-vingt-six');
    });
  });
}
