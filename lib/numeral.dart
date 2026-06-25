/// Lightweight number formatting and parsing for Dart.
///
/// Import the package and create reusable codec instances for the numeric
/// display scenarios in your app:
///
/// ```dart
/// import 'package:numeral/numeral.dart';
/// import 'package:numeral/en.dart' as en;
///
/// final fileSize = BytesCodec.binary(maxFractionDigits: 1);
/// final compact = en.compact(maxFractionDigits: 1);
/// final percent = PercentCodec(maxFractionDigits: 2);
///
/// fileSize.format(1536); // 1.5 KiB
/// fileSize.encode(1536); // 1.5 KiB
/// compact.format(12345); // 12.3K
/// percent.parse('12.5%'); // 0.125
/// ```
library;

export 'src/codec.dart';
export 'src/codec/bytes.dart';
export 'src/codec/compact.dart';
export 'src/codec/currency.dart';
export 'src/codec/decimal.dart';
export 'src/codec/percent.dart';
export 'src/language.dart';
export 'src/rounding.dart';
export 'src/unit.dart';
