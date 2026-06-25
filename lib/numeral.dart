/// Lightweight number formatting and parsing for Dart.
///
/// Import the package with an alias and create reusable formatter instances for
/// numeric display scenarios in your app:
///
/// ```dart
/// import 'package:numeral/numeral.dart' as numeral;
///
/// final fileSize = numeral.BytesFormatter.binary(maxFractionDigits: 1);
/// final compact = numeral.CompactFormatter(maxFractionDigits: 1);
/// final percent = numeral.PercentFormatter(maxFractionDigits: 2);
///
/// fileSize.format(1536); // 1.5 KiB
/// compact.format(12345); // 12.3K
/// percent.parse('12.5%'); // 0.125
/// ```
library;

export 'src/numeral.dart';
