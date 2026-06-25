import 'package:numeral/numeral.dart';

void main() {
  final decimal = DecimalCodec(
    minFractionDigits: 2,
    maxFractionDigits: 2,
  );
  final compact = CompactCodec(maxFractionDigits: 1);
  final percent = PercentCodec(maxFractionDigits: 2);
  final fileSize = BytesCodec.binary(maxFractionDigits: 1);
  final usd = CurrencyCodec(r'$');

  print(decimal.format(1234567.8)); // 1,234,567.80
  print(compact.format(12345)); // 12.3K
  print(compact.parse('12.3K')); // 12300
  print(percent.format(0.1234)); // 12.34%
  print(percent.parse('12.34%')); // 0.1234
  print(fileSize.format(1536)); // 1.5 KiB
  print(fileSize.parse('1.5 KiB')); // 1536
  print(usd.format(1234.5)); // $1,234.50
}
