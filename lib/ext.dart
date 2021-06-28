library numeral;

import 'src/numeral.dart';

extension ExtensionNumeral on num {
  /// Get the number of numeral.
  /// 
  /// Example:
  /// ```dart
  /// 10000.numeral() // 10K
  /// ```
  String numeral({int fractionDigits = 3}) {
    return Numeral(this).value(fractionDigits: fractionDigits);
  }
}
