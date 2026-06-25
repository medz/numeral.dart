/// Rounding behavior used by numeric codecs.
enum Rounding {
  /// Round to the nearest representable fraction digit.
  halfUp,

  /// Drop extra fraction digits without rounding.
  truncate,
}
