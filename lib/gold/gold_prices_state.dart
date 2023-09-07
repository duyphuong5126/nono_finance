import 'package:freezed_annotation/freezed_annotation.dart';

import 'gold_price_type.dart';

part 'gold_prices_state.freezed.dart';

@freezed
sealed class GoldPricesState with _$GoldPricesState {
  @Implements<GoldPricesInitialState>()
  const factory GoldPricesState.initial() = Initial;

  @Implements<GoldPricesInitializedState>()
  const factory GoldPricesState.initialized({
    required Map<String, double> buyingPricesMap,
    required Map<String, double> sellingPricesMap,
    required GoldPriceType type,
  }) = Initialized;

  @Implements<GoldPricesFailureState>()
  const factory GoldPricesState.failure({
    required GoldPriceType type,
  }) = Failure;
}

abstract class GoldPricesInitialState implements GoldPricesState {}

abstract class GoldPricesInitializedState implements GoldPricesState {
  Map<String, double> get buyingPricesMap;

  Map<String, double> get sellingPricesMap;

  GoldPriceType get type;
}

abstract class GoldPricesFailureState implements GoldPricesState {
  GoldPriceType get type;
}
