import 'package:freezed_annotation/freezed_annotation.dart';

part 'gold_prices.freezed.dart';

@freezed
class GoldPrices with _$GoldPrices {
  const factory GoldPrices({
    required Iterable<GoldSeller> domesticPrices,
    required GoldPriceHistory globalPriceHistory,
  }) = _GoldPrices;
}

@freezed
class GoldSeller with _$GoldSeller {
  const factory GoldSeller({
    required String areaName,
    required String seller,
    required double buyingPrice,
    required double sellingPrice,
  }) = _GoldSeller;
}

@freezed
class GoldPriceHistory with _$GoldPriceHistory {
  const factory GoldPriceHistory({
    required double priceInDollar,
    required double priceChangeInDollar,
    required double priceChangeInPercent,
  }) = _GoldPriceHistory;
}
