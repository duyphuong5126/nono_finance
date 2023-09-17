import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nono_finance/domain/entity/bank.dart';
import 'package:nono_finance/infrastructure/data_parsing_helper.dart';
import 'package:nono_finance/util.dart';

import '../crawler/crawlers.dart';
import '../domain/entity/bank_exchange.dart';
import '../domain/entity/currency.dart';
import '../domain/entity/currency_list_result.dart';
import '../domain/repository/exchange_repository.dart';

class ExchangeRepositoryImpl implements ExchangeRepository {
  late CurrencyListResult _currencyListResult;
  int _lastUpdatedTime = -1;

  @override
  Future<CurrencyListResult> getCurrencyList() {
    StreamController<CurrencyListResult> dataStream =
        StreamController.broadcast();
    callbackByCrawlerMap[currenciesCrawler]?.add((data) async {
      _currencyListResult = await compute(_convertCurrencyData, data);
      _lastUpdatedTime = DateTime.now().millisecondsSinceEpoch;
      dataStream.add(_currencyListResult);
    });
    currenciesCrawler.loadUrl(urlByCrawlerMap[currenciesCrawler]!);
    return dataStream.stream.first;
  }

  static CurrencyListResult _convertCurrencyData(
    Map<String, dynamic> currencyData,
  ) {
    final updatedTime = getUpdatedTime(currencyData) ?? DateTime.now();

    final currencies =
        (currencyData['currencies'] as Iterable<dynamic>).map((e) {
      final json = e as Map<String, dynamic>;

      final url = json['url'];
      final urlFrags = url.split('/');
      final currencyCode = urlFrags.elementAt(urlFrags.length - 2);
      final name =
          json['title'].toString().replaceFirst('Tỷ giá ngoại tệ ', '');
      return Currency(code: currencyCode, url: url, defaultName: name);
    });
    return CurrencyListResult(
      currencyList: currencies,
      updatedTime: updatedTime,
    );
  }

  @override
  Future<BankExchange> getBankExchangeList(Currency sourceCurrency) {
    StreamController<BankExchange> dataStream = StreamController.broadcast();
    callbackByCrawlerMap[exchangesCrawler]?.add((exchangeData) async {
      _lastUpdatedTime = DateTime.now().millisecondsSinceEpoch;
      final dataHolder = _ExchangeDataHolder(sourceCurrency, exchangeData);
      dataStream.add(await compute(_parseBankExchangeData, dataHolder));
    });
    errorCallbackByCrawlerMap[exchangesCrawler]?.add((exception) {
      dataStream.addError(exception);
    });
    exchangesCrawler.loadUrl(sourceCurrency.url);
    return dataStream.stream.first;
  }

  static BankExchange _parseBankExchangeData(_ExchangeDataHolder dataHolder) {
    final updatedTime =
        getUpdatedTime(dataHolder.exchangeData) ?? DateTime.now();
    final averageRate =
        double.tryParse(dataHolder.exchangeData['averageRate']) ?? -1.0;
    Map<Bank, double> buyCashMap = {};
    Map<Bank, double> buyTransferMap = {};
    Map<Bank, double> sellCashMap = {};
    Map<Bank, double> sellTransferMap = {};
    final rates = dataHolder.exchangeData['rates'] as List<dynamic>;

    double? tryParse(String str) {
      final result = double.tryParse(str);
      return result?.isNaN == true ? null : result;
    }

    for (final e in rates) {
      final rate = e as Map<String, dynamic>;
      final bankUrl = rate['bankUrl'].toString();
      final frags = bankUrl.split('/');
      String bankCode = '';
      for (var index = frags.length - 1; index >= 0; index--) {
        if (frags[index].isNotEmpty) {
          bankCode = frags[index];
          break;
        }
      }

      final bankName = rate['bankName'].toString();
      final bank = Bank(
        name: bankName.isNotEmpty ? bankName : bankCode,
        code: bankCode,
      );

      const defaultValue = double.negativeInfinity;
      buyCashMap[bank] = tryParse(rate['buyCash']) ?? defaultValue;
      buyTransferMap[bank] = tryParse(rate['buyTransfer']) ?? defaultValue;
      sellCashMap[bank] = tryParse(rate['sellCash']) ?? defaultValue;
      sellTransferMap[bank] = tryParse(rate['sellTransfer']) ?? defaultValue;
    }

    return BankExchange(
      sourceCurrency: dataHolder.sourceCurrency,
      updatedTime: updatedTime,
      averageRate: averageRate,
      buyCashMap: buyCashMap,
      buyTransferMap: buyTransferMap,
      sellCashMap: sellCashMap,
      sellTransferMap: sellTransferMap,
    );
  }
}

class _ExchangeDataHolder {
  final Currency sourceCurrency;
  final Map<String, dynamic> exchangeData;

  const _ExchangeDataHolder(this.sourceCurrency, this.exchangeData);
}
