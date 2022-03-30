library extension;

import 'src/constants.dart';
import 'src/numeral.dart';

extension ExtensionNumeral on num {
  /// Get the number of numeral.
  ///
  /// Example:
  /// ```dart
  /// 10000.numeral() // 10K
  /// ```
  String numeral({int fractionDigits = DEFAULT_FRACTION_DIGITS}) {
    return Numeral(this).format(fractionDigits: fractionDigits);
  }
}
