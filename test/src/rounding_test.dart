import 'package:numeral/src/rounding.dart';
import 'package:test/test.dart';

void main() {
  group('Rounding', () {
    test('defines supported rounding modes', () {
      expect(Rounding.values, [Rounding.halfUp, Rounding.truncate]);
      expect(Rounding.halfUp.name, 'halfUp');
      expect(Rounding.truncate.name, 'truncate');
    });
  });
}
