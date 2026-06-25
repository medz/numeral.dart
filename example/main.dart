import 'package:numeral/en.dart' as en;
import 'package:numeral/extension.dart';
import 'package:numeral/zh.dart' as zh;

void main() {
  final decimal = DecimalCodec(
    minFractionDigits: 2,
    maxFractionDigits: 2,
  );
  final compact = en.compact(maxFractionDigits: 1);
  final percent = PercentCodec(maxFractionDigits: 2);
  final fileSize = BytesCodec.binary(maxFractionDigits: 1);
  final usd = CurrencyCodec(r'$');
  final cny = CurrencyCodec('¥', style: zh.compact(maxFractionDigits: 0));
  final zhWords = zh.cardinal();
  final zhYear = zh.year();
  final zhRmb = zh.rmb();

  print(decimal.format(1234567.8)); // 1,234,567.80
  print(compact.format(12345)); // 12.3K
  print(compact.parse('12.3K')); // 12300
  print(percent.format(0.1234)); // 12.34%
  print(percent.parse('12.34%')); // 0.1234
  print(fileSize.format(1536)); // 1.5 KiB
  print(fileSize.parse('1.5 KiB')); // 1536
  print(1536.bytes(binary: true, maxFractionDigits: 1)); // 1.5 KiB
  print(usd.format(1234.5)); // $1,234.50
  print(cny.format(1000000)); // ¥100万
  print(zhWords.format(1000000)); // 一百万
  print(zhYear.format(2026)); // 二〇二六
  print(zhRmb.format(1000000)); // 人民币壹佰万元整
}
