## 4.1.0

- Added a built-in `es.dart` language path with Spanish compact units and
  cardinal number formatting/parsing.
- Added a built-in `ja.dart` language path with Japanese compact units,
  cardinal number formatting/parsing, and digit-by-digit year formatting.
- Added a built-in `ko.dart` language path with Korean compact units,
  Sino-Korean cardinal numbers, and year numbers.
- Added a built-in `fr.dart` language path with French compact units,
  cardinal number formatting/parsing, and year numbers.
- Added a built-in `zh_hant.dart` language path with Traditional Chinese
  compact units, cardinal numbers, year numbers, and financial numerals.

## 4.0.0

- Rebuilt the public API around reusable codec classes such as
  `DecimalCodec`, `CompactCodec`, `PercentCodec`,
  `BytesCodec`, and `CurrencyCodec`.
- Added reusable immutable codecs with standard `encode`/`decode` support and
  readable `format`, `parse`, and `tryParse` aliases.
- Added direct parsing support for decimal numbers, compact suffixes,
  percentages, byte sizes, and display currency values.
- Added decimal and binary byte codecs.
- Added reusable `NumeralUnit` / `NumeralUnitSet` models for unit-based codecs.
- Added custom number `style` support for unit-style codecs, allowing currency,
  percentage, byte, and compact formats to compose with language-specific
  number codecs.
- Added `extension.dart` for fluent one-off formatting, such as
  `12345.compact()`, `1536.bytes(binary: true)`, and `123.currency(r'$')`.
- Added built-in `en.dart` and `zh.dart` language paths with locale-specific
  compact units, including Simplified Chinese cardinal, year, financial
  numeral, and RMB uppercase amount formatting and parsing.
- Removed the old `num.numeral()` / `beautiful` extension API.

## 3.1.2

- Handle infinite and NaN values in toStringAsFixedNotRound

## 3.1.1

- Fixed the issue that the number after the decimal point was incorrect due to inappropriate rounding.
- test: Added tests

## 3.1.0

- **feat**: Added global conf to choose if value should be rounded. [#17](https://github.com/medz/numeral.dart/pull/17) at [@luis901101](https://github.com/luis901101)

## 3.0.0

- Refactoring code.
- Support custom unit builder.

## [2.0.1]

- Fixed readme extension.

## [2.0.0]

💥 Refactoring

- `number` -> `numeral`
- `format()` -> `format()`
- `factory Numeral()` -> `const Numeral()`

## [1.2.5]

- Fixed [#7](https://github.com/medz/numeral.dart/issues/7) Formatted value is wrong when fractionDigits is set to 0.

## [1.2.1]

optimization.

```dart
import 'package:numeral/numeral.dart';

Numeral(1000).value(); // -> 1K
numeral(1000); // -> 1K
1000.numeral(); // -> 1K
```
