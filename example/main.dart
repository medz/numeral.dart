import 'package:numeral/numeral.dart';

void main() {
  final decimal = DecimalFormatter(
    minFractionDigits: 2,
    maxFractionDigits: 2,
  );
  final compact = CompactFormatter(maxFractionDigits: 1);
  final percent = PercentFormatter(maxFractionDigits: 2);
  final fileSize = BytesFormatter.binary(maxFractionDigits: 1);
  final usd = CurrencyFormatter(r'$');

  print(decimal.format(1234567.8)); // 1,234,567.80
  print(compact.format(12345)); // 12.3K
  print(compact.parse('12.3K')); // 12300
  print(percent.format(0.1234)); // 12.34%
  print(percent.parse('12.34%')); // 0.1234
  print(fileSize.format(1536)); // 1.5 KiB
  print(fileSize.parse('1.5 KiB')); // 1536
  print(usd.format(1234.5)); // $1,234.50
}
