import 'package:numeral/numeral.dart';

void main() {
  // number < 1 thousand.
  Numeral(520).value(); // > 520

  // number >= 1 thousand.
  Numeral(1314).value(); // > 1.314K

  // number >= 1 million.
  Numeral(1000000).value(); // > 1M

  // number >= 1 billion.
  Numeral(1000000000).value(); // > 1B

  // number >= 1 trillion.
  Numeral(1000000000000).value(); // > 1T
}
