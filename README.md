# Numeral

Lightweight number formatting and parsing for Dart.

Numeral focuses on the display formats that application code reaches for every
day: decimals, compact numbers, percentages, byte sizes, and simple currency
strings. Create a codec once, keep it in your app utilities, and use it for both
formatting and parsing.

## Installation

Add Numeral to your `pubspec.yaml`:

```yaml
dependencies:
  numeral: ^4.0.0
```

## Usage

Import the package:

```dart
import 'package:numeral/numeral.dart';
```

Create reusable codec instances:

```dart
final fileSize = BytesCodec.binary(maxFractionDigits: 1);
final compact = CompactCodec(maxFractionDigits: 1);
final ratio = PercentCodec(maxFractionDigits: 2);

fileSize.format(1536); // 1.5 KiB
fileSize.parse('1.5 KiB'); // 1536
fileSize.encode(1536); // 1.5 KiB
fileSize.decode('1.5 KiB'); // 1536

compact.format(12345); // 12.3K
compact.parse('12.3K'); // 12300

ratio.format(0.1234); // 12.34%
ratio.parse('12.34%'); // 0.1234
```

## Codecs

Each codec extends `Codec<T, String>` from `dart:convert`.

`format` and `parse` are readable aliases for `encode` and `decode`, so both
styles work:

```dart
final bytes = BytesCodec.binary();

bytes.format(1024); // 1 KiB
bytes.encode(1024); // 1 KiB
bytes.parse('1 KiB'); // 1024
bytes.decode('1 KiB'); // 1024
```

### Decimal

```dart
final amount = DecimalCodec(
  minFractionDigits: 2,
  maxFractionDigits: 2,
);

amount.format(1234567.8); // 1,234,567.80
amount.parse('1,234,567.80'); // 1234567.8
```

### Compact

```dart
final compact = CompactCodec(maxFractionDigits: 1);

compact.format(1234); // 1.2K
compact.format(999999); // 1M
compact.parse('3 million'); // 3000000
```

Chinese compact units are built in:

```dart
final zh = CompactCodec(unitSet: CompactUnitSet.chinese);

zh.format(1234567); // 123.46万
zh.parse('3.5万'); // 35000
```

### Percent

```dart
final percent = PercentCodec(maxFractionDigits: 1);

percent.format(0.1234); // 12.3%
percent.parse('12.3%'); // 0.123
```

### Bytes

```dart
final decimalBytes = BytesCodec();
final binaryBytes = BytesCodec.binary(maxFractionDigits: 1);

decimalBytes.format(1500); // 1.5 KB
decimalBytes.parse('1.5 MB'); // 1500000

binaryBytes.format(1536); // 1.5 KiB
binaryBytes.parse('1.5 KiB'); // 1536
```

### Currency

Currency formatting is display-oriented. Use a decimal or money type for
financial calculation, then use Numeral to render and parse strings.

```dart
final usd = CurrencyCodec(r'$');

usd.format(1234.5); // $1,234.50
usd.parse(r'$1,234.50'); // 1234.5
```

## Parsing

Every codec has `parse` and `tryParse`:

```dart
final bytes = BytesCodec.binary();

bytes.parse('1 KiB'); // 1024
bytes.tryParse('bad input'); // null
```

`parse` returns the natural numeric type for the codec:

- `DecimalCodec.parse(...)` returns `num`.
- `CompactCodec.parse(...)` returns `num`.
- `PercentCodec.parse(...)` returns `double`.
- `BytesCodec.parse(...)` returns `int`.
- `CurrencyCodec.parse(...)` returns `num`.

## License

This library is licensed under the MIT License.
