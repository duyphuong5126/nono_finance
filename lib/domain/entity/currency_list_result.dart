import 'package:freezed_annotation/freezed_annotation.dart';

import 'currency.dart';

part 'currency_list_result.freezed.dart';

@freezed
class CurrencyListResult with _$CurrencyListResult {
  const factory CurrencyListResult({
    required Iterable<Currency> currencyList,
    required DateTime updatedTime,
  }) = _CurrencyListResult;
}
