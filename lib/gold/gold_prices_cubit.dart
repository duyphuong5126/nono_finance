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

    double highestPrice = 0.0;
    double lowestPrice = double.maxFinite;
    String highestPriceTag = '';
    String lowestPriceTag = '';

    for (final goldSeller
        in goldPrices.domesticPrices.sortedBy((e) => e.areaName)) {
      final seller = '${goldSeller.seller}\n${goldSeller.areaName}';
      final buyingPrice = goldSeller.buyingPrice / 1000000;
      final sellingPrice = goldSeller.sellingPrice / 1000000;
      buyingPricesMap[seller] = buyingPrice;
      sellingPricesMap[seller] = sellingPrice;

      if (buyingPrice >= highestPrice) {
        highestPrice = buyingPrice;
        highestPriceTag =
            'Giá cao nhất (mua vào): ${priceFormat.format(buyingPrice)}tr';
      } else if (sellingPrice >= highestPrice) {
        highestPrice = sellingPrice;
        highestPriceTag =
            'Giá cao nhất (bán ra): ${priceFormat.format(sellingPrice)}tr';
      }

      if (buyingPrice <= lowestPrice) {
        lowestPrice = buyingPrice;
        lowestPriceTag =
            'Giá thấp nhất (mua vào): ${priceFormat.format(buyingPrice)}tr';
      } else if (sellingPrice <= lowestPrice) {
        lowestPrice = sellingPrice;
        lowestPriceTag =
            'Giá thấp nhất (bán ra): ${priceFormat.format(sellingPrice)}tr';
      }
    }

    final highlightData = GoldHighlightData(
      highestPriceTag: highestPriceTag,
      lowestPriceTag: lowestPriceTag,
      globalPriceChange: _getGlobalPriceChange(goldPrices),
    );

    emit(
      GoldPricesState.full(
        buyingPricesMap: buyingPricesMap,
        sellingPricesMap: sellingPricesMap,
        type: GoldPriceType.full,
        highlightData: highlightData,
      ),
    );
  }

  _updatePartialData(GoldPrices goldPrices, GoldPriceType type) async {
    Map<String, double> pricesMap = {};

    double highestPrice = 0.0;
    double lowestPrice = double.maxFinite;
    String highestPriceTag = '';
    String lowestPriceTag = '';
    for (final goldSeller
        in goldPrices.domesticPrices.sortedBy((e) => e.areaName)) {
      final seller = '${goldSeller.seller}\n${goldSeller.areaName}';
      if (type == GoldPriceType.buying) {
        final buyingPrice = goldSeller.buyingPrice / 1000000;
        pricesMap[seller] = buyingPrice;
        if (buyingPrice >= highestPrice) {
          highestPrice = buyingPrice;
          highestPriceTag = 'Giá cao nhất: ${priceFormat.format(buyingPrice)}';
        }
        if (buyingPrice <= lowestPrice) {
          lowestPrice = buyingPrice;
          lowestPriceTag = 'Giá thấp nhất: ${priceFormat.format(buyingPrice)}';
        }
      } else if (type == GoldPriceType.selling) {
        final sellingPrice = goldSeller.sellingPrice / 1000000;
        pricesMap[seller] = sellingPrice;
        if (sellingPrice >= highestPrice) {
          highestPrice = sellingPrice;
          highestPriceTag = 'Giá cao nhất: ${priceFormat.format(sellingPrice)}';
        }
        if (sellingPrice <= lowestPrice) {
          lowestPrice = sellingPrice;
          lowestPriceTag = 'Giá thấp nhất: ${priceFormat.format(sellingPrice)}';
        }
      }
    }

    final highlightData = GoldHighlightData(
      highestPriceTag: highestPriceTag,
      lowestPriceTag: lowestPriceTag,
      globalPriceChange: _getGlobalPriceChange(goldPrices),
    );

    emit(
      GoldPricesState.partial(
        pricesMap: pricesMap,
        type: type,
        highlightData: highlightData,
      ),
    );
  }

  String _getGlobalPriceChange(GoldPrices goldPrices) {
    double priceChangeInDollar =
        goldPrices.globalPriceHistory.priceChangeInDollar;
    double priceChangeInPercent =
        goldPrices.globalPriceHistory.priceChangeInPercent;
    String changeLabel = priceChangeInDollar > 0
        ? 'Tăng: '
        : priceChangeInDollar < 0
            ? 'Giảm: '
            : '';
    String change = priceChangeInDollar != 0
        ? '\$${priceFormat.format(priceChangeInDollar.abs())}, ${priceFormat.format(priceChangeInPercent.abs())}%'
        : '';

    return 'Giá vàng thế giới: \$${priceFormat.format(goldPrices.globalPriceHistory.priceInDollar)}\n'
        '${change.isNotEmpty && changeLabel.isNotEmpty ? '$changeLabel$change\n' : ''}';
  }
}
