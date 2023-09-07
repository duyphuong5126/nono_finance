import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:nono_finance/util.dart';

import '../crawler/crawlers.dart';
import '../domain/entity/gold_prices.dart';
import '../domain/repository/prices_repository.dart';

class PricesRepositoryImpl implements PricesRepository {
  int _lastUpdatedTime = -1;

  @override
  Future<GoldPrices> getGoldPrices() {
    StreamController<GoldPrices> dataStream = StreamController.broadcast();
    callbackByCrawlerMap[goldPricesCrawler]?.add((data) async {
      final result = await compute(_convertGoldPricesData, data);
      _lastUpdatedTime = DateTime.now().millisecondsSinceEpoch;
      dataStream.add(result);
    });
    goldPricesCrawler.loadUrl(urlByCrawlerMap[goldPricesCrawler]!);
    return dataStream.stream.first;
  }

  static GoldPrices _convertGoldPricesData(
    Map<String, dynamic> goldPricesData,
  ) {
    final numberFormat = NumberFormat("#,##0.00", "en_US");
    final List<dynamic> domesticPricesData = goldPricesData['domesticPrices'];
    final domesticPrices = domesticPricesData.where((data) {
      final pricesData = data as Map<String, dynamic>;
      return pricesData.containsKey('buyingPrice') &&
          pricesData.containsKey('sellingPrice');
    }).map((data) {
      final pricesData = data as Map<String, dynamic>;
      final buyingPrice =
          pricesData['buyingPrice'].toString().replaceAll(".", "");
      final sellingPrice =
          pricesData['sellingPrice'].toString().replaceAll(".", "");
      log('Gold>>> buyingPrice=$buyingPrice, sellingPrice=$sellingPrice');
      return GoldSeller(
        areaName: pricesData['areaName'],
        seller: pricesData['seller'],
        buyingPrice: double.parse(buyingPrice) * 10,
        sellingPrice: double.parse(sellingPrice) * 10,
      );
    });
    final globalGoldPriceData =
        goldPricesData['globalPrice'] as Map<String, dynamic>;
    final globalGoldPrice = GoldPriceHistory(
      priceInDollar: numberFormat.parse(
        globalGoldPriceData['price'].toString().replaceAll('\$', ''),
      ) as double,
      priceChangeInDollar: numberFormat
          .parse(globalGoldPriceData['priceChange'].toString()) as double,
      priceChangeInPercent: numberFormat.parse(
        globalGoldPriceData['priceChange'].toString().replaceAll('%', ''),
      ) as double,
    );
    return GoldPrices(
      domesticPrices: domesticPrices,
      globalPriceHistory: globalGoldPrice,
    );
  }
}