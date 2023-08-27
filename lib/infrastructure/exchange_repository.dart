import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nono_finance/util.dart';

import '../crawler/crawlers.dart';
import '../domain/entity/currency.dart';

abstract class ExchangeRepository {
  Future<Iterable<Currency>> getCurrencyList();
}

class ExchangeRepositoryImpl implements ExchangeRepository {
  final List<Currency> _currencies = [];
  int _lastUpdatedTime = -1;

  @override
  Future<Iterable<Currency>> getCurrencyList() {
    StreamController<Iterable<Currency>> dataStream =
        StreamController.broadcast();
    callbackByCrawlerMap[currenciesCrawler]?.add((data) async {
      _currencies.clear();
      _currencies.addAll(await compute(_convertCurrencyData, data));
      _lastUpdatedTime = DateTime.now().millisecondsSinceEpoch;
      dataStream.add(_currencies);
    });
    currenciesCrawler.loadUrl(urlByCrawlerMap[currenciesCrawler]!);
    return dataStream.stream.first;
  }

  static Iterable<Currency> _convertCurrencyData(
    Map<String, dynamic> currencyData,
  ) {
    return (currencyData['currencies'] as Iterable<dynamic>).map((e) {
      final json = e as Map<String, dynamic>;

      final url = json['url'];
      final urlFrags = url.split('/');
      final currencyCode = urlFrags.elementAt(urlFrags.length - 2);
      final name =
          json['title'].toString().replaceFirst('Tỷ giá ngoại tệ ', '');
      return Currency(code: currencyCode, url: url, defaultName: name);
    });
  }
}
