import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/entity/currency.dart';

part 'currency_list_state.freezed.dart';

@freezed
sealed class CurrencyListState with _$CurrencyListState {
  @Implements<CurrencyListInitialState>()
  const factory CurrencyListState.initial() = Initial;

  @Implements<CurrencyListInitializedState>()
  const factory CurrencyListState.initialized({
    required Iterable<Currency> currencyList,
  }) = Initialized;
}

abstract class CurrencyListInitialState implements CurrencyListState {}

abstract class CurrencyListInitializedState implements CurrencyListState {
  Iterable<Currency> get currencyList;
}
