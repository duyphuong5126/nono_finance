import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:nono_finance/util.dart';

import '../crawler/crawlers.dart';
import '../domain/entity/gas_prices.dart';
import '../domain/entity/gold_prices.dart';
import '../domain/repository/prices_repository.dart';
import 'data_parsing_helper.dart';

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

  @override
  Future<GasPrices> getGasPrices() {
    StreamController<GasPrices> dataStream = StreamController.broadcast();
    callbackByCrawlerMap[gasPricesCrawler]?.add((data) async {
      final result = await compute(_convertGasPricesData, data);
      _lastUpdatedTime = DateTime.now().millisecondsSinceEpoch;
      dataStream.add(result);
    });
    gasPricesCrawler.loadUrl(urlByCrawlerMap[gasPricesCrawler]!);
    return dataStream.stream.first;
  }

  static GasPrices _convertGasPricesData(Map<String, dynamic> gasPricesData) {
    final List<dynamic> domesticPricesData = gasPricesData['domesticPrices'];
    final domesticPrices = domesticPricesData.map((data) {
      final pricesData = data as Map<String, dynamic>;
      final sellerName = pricesData['sellerName'].toString();
      if (sellerName.isNotEmpty) {
        return GasPrice(
          sellerName: pricesData['sellerName'],
          area1Price: double.parse(pricesData['area1Price'].toString()),
          area2Price: double.parse(pricesData['area2Price'].toString()),
        );
      } else {
        return const GasPrice(
          sellerName: 'Unknown',
          area1Price: -1,
          area2Price: -1,
        );
      }
    }).where((gasPrice) => gasPrice.area1Price > 0 && gasPrice.area2Price > 0);
    return GasPrices(domesticPrices: domesticPrices);
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
        globalGoldPriceData['priceChangePercent']
            .toString()
            .replaceAll('%', ''),
      ) as double,
    );
    return GoldPrices(
      domesticPrices: domesticPrices,
      globalPriceHistory: globalGoldPrice,
      updatedTime: getUpdatedTime(goldPricesData) ?? DateTime.now(),
    );
  }
}
