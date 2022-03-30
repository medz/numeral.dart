# Example

```dart
import 'package:numeral/numeral.dart';

void main() {
  // number < 1 thousand.
  Numeral(520).format(); // > 520

  // number >= 1 thousand.
  Numeral(1314).format(); // > 1.314K

  // number >= 1 million.
  Numeral(1000000).format(); // > 1M

  // number >= 1 billion.
  Numeral(1000000000).format(); // > 1B

  // number >= 1 trillion.
  Numeral(1000000000000).format(); // > 1T

  // number <= 0
  Numeral(-1000).format(); // > -1K

  // Using function
  print(numeral(1314)); // > 1.314K

  // Using num extension
  print(1314.numeral()); // > 1.314K
}
```
