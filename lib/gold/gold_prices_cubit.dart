import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:nono_finance/domain/repository/prices_repository.dart';
import 'package:nono_finance/infrastructure/prices_repository_impl.dart';
import 'package:nono_finance/shared/nono_cubit.dart';

import '../domain/entity/gold_prices.dart';
import 'gold_price_type.dart';
import 'gold_prices_state.dart';

class GoldPricesPageCubit extends NonoCubit<GoldPricesState> {
  GoldPricesPageCubit() : super(const GoldPricesState.initial());

  final PricesRepository _repository = PricesRepositoryImpl();
  final priceFormat = NumberFormat("#,##0.00", "en_US");
  late GoldPrices fullPricesData;

  @override
  init() async {
    await changeType(GoldPriceType.full);
  }

  refresh(GoldPriceType type) async {
    emit(const GoldPricesState.initial());
    _refreshData(fullPricesData, type);
  }

  changeType(GoldPriceType type) async {
    emit(const GoldPricesState.initial());
    try {
      fullPricesData = await _repository.getGoldPrices();
      _refreshData(fullPricesData, type);
    } on Exception catch (error) {
      log(
        'GoldPricesPageCubit>>> failed to get gold prices with error',
        error: error,
      );
      emit(GoldPricesState.failure(type: type));
    }
  }

  _refreshData(GoldPrices pricesData, GoldPriceType type) {
    switch (type) {
      case GoldPriceType.full:
        _updateFullData(pricesData);
        break;
      default:
        _updatePartialData(pricesData, type);
        break;
    }
  }

  _updateFullData(GoldPrices goldPrices) async {
    Map<String, double> buyingPricesMap = {};
    Map<String, double> sellingPricesMap = {};

    double highestBuyingPrice = 0.0;
    double lowestBuyingPrice = double.maxFinite;
    double highestSellingPrice = 0.0;
    double lowestSellingPrice = double.maxFinite;

    for (final goldSeller
        in goldPrices.domesticPrices.sortedBy((e) => e.areaName)) {
      final seller = '${goldSeller.seller}\n${goldSeller.areaName}';
      final buyingPrice = goldSeller.buyingPrice / 1000000;
      final sellingPrice = goldSeller.sellingPrice / 1000000;
      buyingPricesMap[seller] = buyingPrice;
      sellingPricesMap[seller] = sellingPrice;

      if (buyingPrice >= highestBuyingPrice) {
        highestBuyingPrice =
            buyingPrice; //'Giá cao nhất (mua vào): ${priceFormat.format(buyingPrice)}tr';
      } else if (sellingPrice >= highestSellingPrice) {
        highestSellingPrice =
            sellingPrice; //'Giá cao nhất (bán ra): ${priceFormat.format(sellingPrice)}tr';
      }

      if (buyingPrice <= lowestBuyingPrice) {
        lowestBuyingPrice =
            buyingPrice; //'Giá thấp nhất (mua vào): ${priceFormat.format(buyingPrice)}tr';
      } else if (sellingPrice <= lowestSellingPrice) {
        lowestSellingPrice =
            sellingPrice; //'Giá thấp nhất (bán ra): ${priceFormat.format(sellingPrice)}tr';
      }
    }

    emit(
      GoldPricesState.full(
        buyingPricesMap: buyingPricesMap,
        sellingPricesMap: sellingPricesMap,
        type: GoldPriceType.full,
        highestBuyingPrice: highestBuyingPrice,
        highestSellingPrice: highestSellingPrice,
        lowestBuyingPrice: lowestBuyingPrice,
        lowestSellingPrice: lowestSellingPrice,
        globalPrice: goldPrices.globalPriceHistory,
      ),
    );
  }

  _updatePartialData(GoldPrices goldPrices, GoldPriceType type) async {
    Map<String, double> pricesMap = {};

    double highestPrice = 0.0;
    double lowestPrice = double.maxFinite;
    for (final goldSeller
        in goldPrices.domesticPrices.sortedBy((e) => e.areaName)) {
      final seller = '${goldSeller.seller}\n${goldSeller.areaName}';
      if (type == GoldPriceType.buying) {
        final buyingPrice = goldSeller.buyingPrice / 1000000;
        pricesMap[seller] = buyingPrice;
        if (buyingPrice >= highestPrice) {
          highestPrice = buyingPrice;
        }
        if (buyingPrice <= lowestPrice) {
          lowestPrice = buyingPrice;
        }
      } else if (type == GoldPriceType.selling) {
        final sellingPrice = goldSeller.sellingPrice / 1000000;
        pricesMap[seller] = sellingPrice;
        if (sellingPrice >= highestPrice) {
          highestPrice = sellingPrice;
        }
        if (sellingPrice <= lowestPrice) {
          lowestPrice = sellingPrice;
        }
      }
    }

    emit(
      GoldPricesState.partial(
        pricesMap: pricesMap,
        type: type,
        highestPrice: highestPrice,
        lowestPrice: lowestPrice,
        globalPrice: goldPrices.globalPriceHistory,
      ),
    );
  }
}
