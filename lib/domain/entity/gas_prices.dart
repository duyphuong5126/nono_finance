import 'package:freezed_annotation/freezed_annotation.dart';

part 'gas_prices.freezed.dart';

@freezed
class GasPrices with _$GasPrices {
  const factory GasPrices({
    required Iterable<GasPrice> domesticPrices,
    required DateTime updatedAt,
  }) = _GasPrices;
}

@freezed
class GasPrice with _$GasPrice {
  const factory GasPrice({
    required String sellerName,
    required double area1Price,
    required double area2Price,
  }) = _GasPrice;
}
