## [2.0.1]

* Fixed readme extension.

## [2.0.0]

💥 Refactoring

 * `number` -> `numeral`
 * `format()` -> `format()`
 * `factory Numeral()` -> `const Numeral()`

## [1.2.5]

 * Fixed [#7](https://github.com/medz/numeral.dart/issues/7) Formatted value is wrong when fractionDigits is set to 0.

## [1.2.1]

optimization.

```dart
import 'package:numeral/numeral.dart';

Numeral(1000).value(); // -> 1K
numeral(1000); // -> 1K
1000.numeral(); // -> 1K
```
