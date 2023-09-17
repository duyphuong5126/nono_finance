import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/entity/gas_prices.dart';

part 'gas_prices_state.freezed.dart';

@freezed
sealed class GasPricesState with _$GasPricesState {
  @Implements<GoldPricesInitialState>()
  const factory GasPricesState.initial() = Initial;

  @Implements<GoldPricesInitializedState>()
  const factory GasPricesState.initialized({
    required Iterable<GasPrice> prices,
    required DateTime updatedAt,
  }) = Initialized;

  @Implements<GoldPricesFailureState>()
  const factory GasPricesState.failure() = Failure;
}

abstract class GoldPricesInitialState implements GasPricesState {}

abstract class GoldPricesInitializedState implements GasPricesState {
  Iterable<GasPrice> get prices;

  DateTime get updatedAt;
}

abstract class GoldPricesFailureState implements GasPricesState {}
