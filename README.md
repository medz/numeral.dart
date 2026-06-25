# Numeral

Lightweight number formatting and parsing for Dart.

Numeral focuses on the display formats that application code reaches for every
day: decimals, compact numbers, percentages, byte sizes, and simple currency
strings. Create a formatter once, keep it in your app utilities, and use it for
both formatting and parsing.

## Installation

Add Numeral to your `pubspec.yaml`:

```yaml
dependencies:
  numeral: ^4.0.0
```

## Usage

Import the package with an alias:

```dart
import 'package:numeral/numeral.dart' as numeral;
```

Create reusable formatter instances:

```dart
final fileSize = numeral.BytesFormatter.binary(maxFractionDigits: 1);
final compact = numeral.CompactFormatter(maxFractionDigits: 1);
final ratio = numeral.PercentFormatter(maxFractionDigits: 2);

fileSize.format(1536); // 1.5 KiB
fileSize.parse('1.5 KiB'); // 1536

compact.format(12345); // 12.3K
compact.parse('12.3K'); // 12300

ratio.format(0.1234); // 12.34%
ratio.parse('12.34%'); // 0.1234
```

## Formatters

### Decimal

```dart
final amount = numeral.DecimalFormatter(
  minFractionDigits: 2,
  maxFractionDigits: 2,
);

amount.format(1234567.8); // 1,234,567.80
amount.parse('1,234,567.80'); // 1234567.8
```

### Compact

```dart
final compact = numeral.CompactFormatter(maxFractionDigits: 1);

compact.format(1234); // 1.2K
compact.format(999999); // 1M
compact.parse('3 million'); // 3000000
```

Chinese compact units are built in:

```dart
final zh = numeral.CompactFormatter(unitSet: numeral.CompactUnitSet.chinese);

zh.format(1234567); // 123.46万
zh.parse('3.5万'); // 35000
```

### Percent

```dart
final percent = numeral.PercentFormatter(maxFractionDigits: 1);

percent.format(0.1234); // 12.3%
percent.parse('12.3%'); // 0.123
```

### Bytes

```dart
final decimalBytes = numeral.BytesFormatter();
final binaryBytes = numeral.BytesFormatter.binary(maxFractionDigits: 1);

decimalBytes.format(1500); // 1.5 KB
decimalBytes.parse('1.5 MB'); // 1500000

binaryBytes.format(1536); // 1.5 KiB
binaryBytes.parse('1.5 KiB'); // 1536
```

### Currency

Currency formatting is display-oriented. Use a decimal or money type for
financial calculation, then use Numeral to render and parse strings.

```dart
final usd = numeral.CurrencyFormatter(r'$');

usd.format(1234.5); // $1,234.50
usd.parse(r'$1,234.50'); // 1234.5
```

## Parsing

Every formatter has `parse` and `tryParse`:

```dart
final bytes = numeral.BytesFormatter.binary();

bytes.parse('1 KiB'); // 1024
bytes.tryParse('bad input'); // null
```

`parse` returns the natural numeric type for the formatter:

- `DecimalFormatter.parse(...)` returns `num`.
- `CompactFormatter.parse(...)` returns `num`.
- `PercentFormatter.parse(...)` returns `double`.
- `BytesFormatter.parse(...)` returns `int`.
- `CurrencyFormatter.parse(...)` returns `num`.

## License

This library is licensed under the MIT License.
