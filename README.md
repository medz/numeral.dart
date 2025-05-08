# Numeral

A Dart library for Format number into beautiful string, Format the number
into a beautiful, readable and short string.

## Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  numeral: latest
```

## Usage

Using it is very simple! Just chain call the `numeral()` method or
`beautiful` attribute after your number (`num`/`int`/`double`)!

```dart
import 'package:numeral/numeral.dart';

void main() {
    print(1000.numeral()); // -> 1K
    print(1000.beautiful); // -> 1K
}
```

## Configuration

- `Numeral.digits` (default: `3`): The number of digits to show after the decimal
  point.
- `Numeral.rounded` (default: `false`): Whether the value should be rounded or not.
- `Numeral.builder` (default: `NumeralUnit.value`): The function to build the
  suffix.

### Global configuration

```dart
import 'package:numeral/numeral.dart';

Numeral.digits = 2;
Numeral.rounded = false;
Numeral.builder = (unit) => '<Your custom suffix>';

```

## License

This library is licensed under the MIT License.
