enum NumeralUnit {
  /// trillion
  trillion('T'),

  /// billion
  billion('B'),

  /// million
  million('M'),

  /// thousand
  thousand('K'),

  /// less than thousand
  less('');

  final String value;
  const NumeralUnit(this.value);
}
