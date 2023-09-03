import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nono_finance/domain/entity/bank.dart';
import 'package:nono_finance/domain/entity/currency.dart';

part 'bank_exchange.freezed.dart';

@freezed
class BankExchange with _$BankExchange {
  const factory BankExchange({
    required Currency sourceCurrency,
    required DateTime updatedTime,
    required double averageRate,
    required Map<Bank, double> buyCashMap,
    required Map<Bank, double> buyTransferMap,
    required Map<Bank, double> sellCashMap,
    required Map<Bank, double> sellTransferMap,
  }) = _BankExchange;
}
