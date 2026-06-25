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
import 'package:numeral/en.dart' as en;
```

Create reusable codec instances:

```dart
final fileSize = BytesCodec.binary(maxFractionDigits: 1);
final compact = en.compact(maxFractionDigits: 1);
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

For one-off formatting, import the extension entry:

```dart
import 'package:numeral/extension.dart';
import 'package:numeral/zh.dart' as zh;

12345.compact(maxFractionDigits: 1); // 12.3K
1536.bytes(binary: true, maxFractionDigits: 1); // 1.5 KiB
1000000.currency('¥', style: zh.compact(maxFractionDigits: 0)); // ¥100万
1000000.formatWith(zh.cardinal()); // 一百万
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

Unit-style codecs such as compact numbers, percentages, byte sizes, and
currency can replace their internal number style with another codec. By
default, they use a `DecimalCodec` built from their decimal options.

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
import 'package:numeral/en.dart' as en;

final compact = en.compact(maxFractionDigits: 1);

compact.format(1234); // 1.2K
compact.format(999999); // 1M
compact.parse('3 million'); // 3000000
```

Custom unit sets use the same `NumeralUnit` model as byte codecs:

```dart
final custom = CompactCodec(
  unitSet: NumeralUnitSet([
    NumeralUnit(1, ''),
    NumeralUnit(1000, 'K', aliases: ['k']),
    NumeralUnit(1000000, 'M', aliases: ['m']),
  ]),
);

custom.format(1234567); // 1.23M
custom.parse('3.5M'); // 3500000
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
import 'package:numeral/zh.dart' as zh;

final usd = CurrencyCodec(r'$');
final cny = CurrencyCodec(
  '¥',
  style: zh.compact(maxFractionDigits: 0),
);

usd.format(1234.5); // $1,234.50
usd.parse(r'$1,234.50'); // 1234.5
cny.format(1000000); // ¥100万
cny.parse('¥100万'); // 1000000
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

## Language Paths

Built-in language packs live behind separate import paths. This keeps the core
API small while allowing locale-specific rules to include code, not only unit
data.

```dart
import 'package:numeral/zh.dart' as zh;

final compact = zh.compact(maxFractionDigits: 2);
final words = zh.cardinal();
final year = zh.year();
final financial = zh.financial();
final rmb = zh.rmb();

compact.format(1234567); // 123.46万
words.format(1000000); // 一百万
words.format(2000000); // 二百万
words.parse('一百万'); // 1000000
words.parse('两百万'); // 2000000
words.parse('一万零十'); // 10010
year.format(2026); // 二〇二六
financial.format(1000000); // 壹佰万
rmb.format(1000000); // 人民币壹佰万元整
rmb.format(1234567.89); // 人民币壹佰贰拾叁万肆仟伍佰陆拾柒元捌角玖分
```

External packages can build the same style of language path by reusing
`NumeralLanguage`, `NumeralUnitSet`, and `NumeralCodec`.

## License

This library is licensed under the MIT License.
