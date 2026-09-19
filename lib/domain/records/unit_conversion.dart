/// Lossless conversions for display. Does not interpret medical ranges.
abstract final class UnitConversion {
  static const kgToLb = 2.2046226218;
  static const mmolToMgDlGlucose = 18.0182;

  static double kilogramsToPounds(double kg) => kg * kgToLb;

  static double poundsToKilograms(double lb) => lb / kgToLb;

  static double celsiusToFahrenheit(double c) => c * 9 / 5 + 32;

  static double fahrenheitToCelsius(double f) => (f - 32) * 5 / 9;

  static double glucoseMmolToMgDl(double mmol) => mmol * mmolToMgDlGlucose;

  static double glucoseMgDlToMmol(double mgDl) => mgDl / mmolToMgDlGlucose;

  static double convert({
    required double value,
    required String fromUnit,
    required String toUnit,
  }) {
    final from = fromUnit.toLowerCase();
    final to = toUnit.toLowerCase();
    if (from == to) return value;
    if (from == 'kg' && to == 'lb') return kilogramsToPounds(value);
    if (from == 'lb' && to == 'kg') return poundsToKilograms(value);
    if (from == 'c' && to == 'f') return celsiusToFahrenheit(value);
    if (from == 'f' && to == 'c') return fahrenheitToCelsius(value);
    if (from == 'mmol/l' && to == 'mg/dl') return glucoseMmolToMgDl(value);
    if (from == 'mg/dl' && to == 'mmol/l') return glucoseMgDlToMmol(value);
    throw ArgumentError('Unsupported conversion $fromUnit → $toUnit');
  }
}
