/// Lightweight number formatting and parsing for Dart.
///
/// Import the package and create reusable formatter instances for the numeric
/// display scenarios in your app:
///
/// ```dart
/// import 'package:numeral/numeral.dart';
///
/// final fileSize = BytesFormatter.binary(maxFractionDigits: 1);
/// final compact = CompactFormatter(maxFractionDigits: 1);
/// final percent = PercentFormatter(maxFractionDigits: 2);
///
/// fileSize.format(1536); // 1.5 KiB
/// compact.format(12345); // 12.3K
/// percent.parse('12.5%'); // 0.125
/// ```
library;

export 'src/numeral.dart';
