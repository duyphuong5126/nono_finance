import 'dart:async';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:nono_finance/util.dart';

import '../crawler/crawlers.dart';
import '../domain/entity/currency.dart';
import '../domain/entity/currency_list_result.dart';

abstract class ExchangeRepository {
  Future<CurrencyListResult> getCurrencyList();
}

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
    log('Datetime>>> ${currencyData['updatedTime']}');
    final dateTimeFrags = currencyData['updatedTime']
        .toString()
        .split(' ')
        .whereNot((e) => e.isEmpty);

    String dateString = '';
    String timeString = '';
    for (final frag in dateTimeFrags) {
      if (frag.contains(':')) {
        timeString = frag;
      } else if (frag.contains('/')) {
        dateString = frag;
      }
    }

    final datetimeFormat = DateFormat("hh:mm:ss dd/MM/yyyy");

    log('Datetime>>> parsed date time =$dateString $timeString');
    final updatedTime = dateString.isNotEmpty && timeString.isNotEmpty
        ? datetimeFormat.parse('$timeString $dateString')
        : DateTime.now();

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
}
