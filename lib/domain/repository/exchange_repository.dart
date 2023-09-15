import '../entity/bank_exchange.dart';
import '../entity/currency.dart';
import '../entity/currency_list_result.dart';

abstract class ExchangeRepository {
  Future<CurrencyListResult> getCurrencyList();

  Future<BankExchange> getBankExchangeList(Currency sourceCurrency);
}
