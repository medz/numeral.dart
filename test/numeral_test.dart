import 'package:numeral/numeral.dart';
import 'package:test/test.dart';

void testNotRounded() {}

void main() {
  group('Not Rounded', () {
    final rounded = false;

    test('Edge cases for small numbers', () {
      expect(0.numeral(rounded: rounded), '0');
      expect(0.001.numeral(digits: 4, rounded: rounded), '0.001');
      expect(0.0001.numeral(digits: 4, rounded: rounded), '0.0001');
      expect(0.00001.numeral(digits: 4, rounded: rounded), '0');
      expect((-0.0001).numeral(digits: 4, rounded: rounded), '-0.0001');
    });

    test('Negative numbers', () {
      expect((-1000).numeral(rounded: rounded), '-1K');
      expect((-123456).numeral(digits: 2, rounded: rounded), '-123.45K');
    });

    test('Zero digits', () {
      expect(1234.numeral(digits: 0, rounded: rounded), '1K');
      expect(999.numeral(digits: 0, rounded: rounded), '999');
    });

    test('Custom builder', () {
      String customBuilder(NumeralUnit unit) => '${unit.value}!';
      expect(1000.numeral(builder: customBuilder, rounded: rounded), '1K!');
    });

    test('From [1, K)', () {
      final digits = 3;
      expect(1.numeral(digits: digits, rounded: rounded), '1');
      expect(1.1.numeral(digits: digits, rounded: rounded), '1.1');
      expect(1.12.numeral(digits: digits, rounded: rounded), '1.12');
      expect(1.123.numeral(digits: digits, rounded: rounded), '1.123');
      expect(1.1234.numeral(digits: digits, rounded: rounded), '1.123');
      expect(1.4567.numeral(digits: digits, rounded: rounded), '1.456');
      expect(10.numeral(digits: digits, rounded: rounded), '10');
      expect(100.numeral(digits: digits, rounded: rounded), '100');
      expect(150.numeral(digits: digits, rounded: rounded), '150');
      expect(190.numeral(digits: digits, rounded: rounded), '190');
      expect(199.numeral(digits: digits, rounded: rounded), '199');
    });

    test('From [K, M)', () {
      int digits = 3;
      expect(1000.numeral(digits: digits, rounded: rounded), '1K');
      expect(1001.numeral(digits: digits, rounded: rounded), '1.001K');
      expect(1010.numeral(digits: digits, rounded: rounded), '1.01K');
      expect(1100.numeral(digits: digits, rounded: rounded), '1.1K');
      expect(1011.numeral(digits: digits, rounded: rounded), '1.011K');
      expect(1101.numeral(digits: digits, rounded: rounded), '1.101K');
      expect(1111.numeral(digits: digits, rounded: rounded), '1.111K');

      digits = 2;
      expect(123456.numeral(digits: digits, rounded: rounded), '123.45K');
      expect(456789.numeral(digits: digits, rounded: rounded), '456.78K');
    });

    test('From [M, B)', () {
      int digits = 3;
      expect(123456789.numeral(digits: digits, rounded: rounded), '123.456M');
      expect(999999999.numeral(digits: digits, rounded: rounded), '999.999M');

      digits = 1;
      expect(4567899.numeral(digits: digits, rounded: rounded), '4.5M');
      expect(9999999.numeral(digits: digits, rounded: rounded), '9.9M');
    });

    test('From [B, T)', () {
      int digits = 3;
      expect(
          123456789123.numeral(digits: digits, rounded: rounded), '123.456B');
      expect(
          999999999999.numeral(digits: digits, rounded: rounded), '999.999B');

      digits = 1;
      expect(456789999999.numeral(digits: digits, rounded: rounded), '456.7B');
      expect(999999999999.numeral(digits: digits, rounded: rounded), '999.9B');
    });

    test('From [T, ∞)', () {
      int digits = 3;
      expect(123456789123456.numeral(digits: digits, rounded: rounded),
          '123.456T');
      expect(999999999999999.numeral(digits: digits, rounded: rounded),
          '999.999T');

      digits = 1;
      expect(
          456789999999999.numeral(digits: digits, rounded: rounded), '456.7T');
      expect(
          999999999999999.numeral(digits: digits, rounded: rounded), '999.9T');
    });
  });

  group('Rounded', () {
    final rounded = true;

    test('Edge cases for small numbers', () {
      expect(0.numeral(rounded: rounded), '0');
      expect(0.001.numeral(digits: 4, rounded: rounded), '0.001');
      expect(0.0001.numeral(digits: 4, rounded: rounded), '0.0001');
      expect(0.00001.numeral(digits: 4, rounded: rounded), '0');
      expect((-0.0001).numeral(digits: 4, rounded: rounded), '-0.0001');
    });

    test('Negative numbers', () {
      expect((-1000).numeral(rounded: rounded), '-1K');
      expect((-123456).numeral(digits: 2, rounded: rounded), '-123.46K');
    });

    test('Zero digits', () {
      expect(1234.numeral(digits: 0, rounded: rounded), '1K');
      expect(999.numeral(digits: 0, rounded: rounded), '999');
    });

    test('Custom builder', () {
      String customBuilder(NumeralUnit unit) => '${unit.value}!';
      expect(1000.numeral(builder: customBuilder, rounded: rounded), '1K!');
    });

    test('From [1, K)', () {
      final digits = 3;
      expect(1.numeral(digits: digits, rounded: rounded), '1');
      expect(1.1.numeral(digits: digits, rounded: rounded), '1.1');
      expect(1.12.numeral(digits: digits, rounded: rounded), '1.12');
      expect(1.123.numeral(digits: digits, rounded: rounded), '1.123');
      expect(1.1234.numeral(digits: digits, rounded: rounded), '1.123');
      expect(1.4567.numeral(digits: digits, rounded: rounded), '1.457');
      expect(10.numeral(digits: digits, rounded: rounded), '10');
      expect(100.numeral(digits: digits, rounded: rounded), '100');
      expect(150.numeral(digits: digits, rounded: rounded), '150');
      expect(190.numeral(digits: digits, rounded: rounded), '190');
      expect(199.numeral(digits: digits, rounded: rounded), '199');
    });

    test('From [K, M)', () {
      int digits = 3;
      expect(1000.numeral(digits: digits, rounded: rounded), '1K');
      expect(1001.numeral(digits: digits, rounded: rounded), '1.001K');
      expect(1010.numeral(digits: digits, rounded: rounded), '1.01K');
      expect(1100.numeral(digits: digits, rounded: rounded), '1.1K');
      expect(1011.numeral(digits: digits, rounded: rounded), '1.011K');
      expect(1101.numeral(digits: digits, rounded: rounded), '1.101K');
      expect(1111.numeral(digits: digits, rounded: rounded), '1.111K');

      digits = 2;
      expect(123456.numeral(digits: digits, rounded: rounded), '123.46K');
      expect(456789.numeral(digits: digits, rounded: rounded), '456.79K');
    });

    test('From [M, B)', () {
      int digits = 3;
      expect(123456789.numeral(digits: digits, rounded: rounded), '123.457M');
      expect(999999999.numeral(digits: digits, rounded: rounded), '1000M');

      digits = 1;
      expect(4567899.numeral(digits: digits, rounded: rounded), '4.6M');
      expect(9999999.numeral(digits: digits, rounded: rounded), '10M');
    });

    test('From [B, T)', () {
      int digits = 3;
      expect(
          123456789123.numeral(digits: digits, rounded: rounded), '123.457B');
      expect(999999999999.numeral(digits: digits, rounded: rounded), '1000B');

      digits = 1;
      expect(456789999999.numeral(digits: digits, rounded: rounded), '456.8B');
      expect(999999999999.numeral(digits: digits, rounded: rounded), '1000B');
    });

    test('From [T, ∞)', () {
      int digits = 3;
      expect(123456789123456.numeral(digits: digits, rounded: rounded),
          '123.457T');
      expect(
          999999999999999.numeral(digits: digits, rounded: rounded), '1000T');

      digits = 1;
      expect(
          456789999999999.numeral(digits: digits, rounded: rounded), '456.8T');
      expect(
          999999999999999.numeral(digits: digits, rounded: rounded), '1000T');
    });
  });

  test('Global confs', () {
    Numeral.digits = 1;
    Numeral.rounded = true;
    expect(1080.beautiful, '1.1K');
    expect(6470.beautiful, '6.5K');
    expect(45676000.beautiful, '45.7M');
    expect(65785676000.beautiful, '65.8B');
    expect(9999999999999.beautiful, '10T');
    Numeral.rounded = false;
    expect(1080.beautiful, '1K');
    expect(6470.beautiful, '6.4K');
    expect(45676000.beautiful, '45.6M');
    expect(9999999999999.beautiful, '9.9T');

    Numeral.builder = (unit) => '${unit.value}!!!';
    expect(1000.beautiful, '1K!!!');
    Numeral.builder = Numeral.defaultBuilder; // Reset to default
  });
}
