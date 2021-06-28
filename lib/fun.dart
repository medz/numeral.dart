library numeral;

import 'src/numeral.dart';

/// Get a formated string on numeral.
/// 
/// [value] Need parse [num] value.
/// The parameter [fractionDigits] must be an integer satisfying.
/// 
/// example:
/// ```dart
/// numeral(10000) // => 10K
/// ```
String numeral(num value, {int fractionDigits = 3}) =>
    Numeral(value).value(fractionDigits: fractionDigits);
