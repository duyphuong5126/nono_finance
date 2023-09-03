import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nono_finance/domain/entity/currency.dart';
import 'package:nono_finance/domain/entity/exchange_type.dart';

part 'exchange_page_state.freezed.dart';

@freezed
sealed class ExchangePageState with _$ExchangePageState {
  @Implements<ExchangePageInitialState>()
  const factory ExchangePageState.initial() = Initial;

  @Implements<ExchangePageInitializedState>()
  const factory ExchangePageState.initialized({
    required Map<String, Map<String, double>> exchangesByGroup,
    required Currency fromCurrency,
    required ExchangeType type,
  }) = Initialized;
}

abstract class ExchangePageInitialState implements ExchangePageState {}

abstract class ExchangePageInitializedState implements ExchangePageState {
  Map<String, Map<String, double>> get exchangesByGroup;

  Currency get fromCurrency;

  ExchangeType get type;
}
