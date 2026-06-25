/// Lightweight number formatting and parsing for Dart.
///
/// Import the package and create reusable codec instances for the numeric
/// display scenarios in your app:
///
/// ```dart
/// import 'package:numeral/numeral.dart';
///
/// final fileSize = BytesCodec.binary(maxFractionDigits: 1);
/// final compact = CompactCodec(maxFractionDigits: 1);
/// final percent = PercentCodec(maxFractionDigits: 2);
///
/// fileSize.format(1536); // 1.5 KiB
/// fileSize.encode(1536); // 1.5 KiB
/// compact.format(12345); // 12.3K
/// percent.parse('12.5%'); // 0.125
/// ```
library;

export 'src/bytes_codec.dart';
export 'src/compact_codec.dart';
export 'src/currency_codec.dart';
export 'src/decimal_codec.dart';
export 'src/numeral_codec.dart';
export 'src/percent_codec.dart';
export 'src/rounding.dart';
