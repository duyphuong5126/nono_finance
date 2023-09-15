import 'package:freezed_annotation/freezed_annotation.dart';

part 'gas_prices.freezed.dart';

@freezed
class GasPrices with _$GasPrices {
  const factory GasPrices({
    required Iterable<GasPrice> domesticPrices,
  }) = _GasPrices;
}

class GasPrice {
  final String sellerName;
  final double area1Price;
  final double area2Price;

  const GasPrice({
    required this.sellerName,
    required this.area1Price,
    required this.area2Price,
  });
}
