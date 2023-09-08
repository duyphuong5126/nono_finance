import 'package:freezed_annotation/freezed_annotation.dart';

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
    required GoldPriceType type,
  }) = Full;

  @Implements<GoldPricesPartialState>()
  const factory GoldPricesState.partial({
    required Map<String, double> pricesMap,
    required GoldPriceType type,
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

  GoldPriceType get type;
}

abstract class GoldPricesPartialState implements GoldPricesState {
  Map<String, double> get pricesMap;

  GoldPriceType get type;
}

abstract class GoldPricesFailureState implements GoldPricesState {
  GoldPriceType get type;
}
