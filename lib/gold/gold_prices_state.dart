import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/entity/gold_prices.dart';
import 'gold_price_type.dart';

part 'gold_prices_state.freezed.dart';

@freezed
sealed class GoldPricesState with _$GoldPricesState {
  @Implements<GoldPricesInitialState>()
  const factory GoldPricesState.initial() = Initial;

  @Implements<GoldPricesFullState>()
  const factory GoldPricesState.full({
    required Map<String, double> buyingPricesMap,
    required Map<String, double> sellingPricesMap,
    required double highestBuyingPrice,
    required double lowestBuyingPrice,
    required double highestSellingPrice,
    required double lowestSellingPrice,
    required GoldPriceHistory globalPrice,
    required GoldPriceType type,
    required DateTime updatedAt,
  }) = Full;

  @Implements<GoldPricesPartialState>()
  const factory GoldPricesState.partial({
    required Map<String, double> pricesMap,
    required double highestPrice,
    required double lowestPrice,
    required GoldPriceHistory globalPrice,
    required GoldPriceType type,
    required DateTime updatedAt,
  }) = Partial;

  @Implements<GoldPricesFailureState>()
  const factory GoldPricesState.failure({
    required GoldPriceType type,
  }) = Failure;
}

abstract class GoldPricesInitialState implements GoldPricesState {}

abstract class GoldPricesFullState implements GoldPricesState {
  Map<String, double> get buyingPricesMap;

  Map<String, double> get sellingPricesMap;

  double get highestBuyingPrice;

  double get lowestBuyingPrice;

  double get highestSellingPrice;

  double get lowestSellingPrice;

  GoldPriceHistory get globalPrice;

  GoldPriceType get type;

  DateTime get updatedAt;
}

abstract class GoldPricesPartialState implements GoldPricesState {
  Map<String, double> get pricesMap;

  double get highestPrice;

  double get lowestPrice;

  GoldPriceHistory get globalPrice;

  GoldPriceType get type;

  DateTime get updatedAt;
}

abstract class GoldPricesFailureState implements GoldPricesState {
  GoldPriceType get type;
}
