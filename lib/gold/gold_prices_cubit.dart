import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:nono_finance/domain/repository/prices_repository.dart';
import 'package:nono_finance/infrastructure/prices_repository_impl.dart';
import 'package:nono_finance/shared/nono_cubit.dart';

import '../domain/entity/gold_prices.dart';
import 'gold_price_type.dart';
import 'gold_prices_state.dart';

class GoldPricesPageCubit extends NonoCubit<GoldPricesState> {
  GoldPricesPageCubit() : super(const GoldPricesState.initial());

  final PricesRepository _repository = PricesRepositoryImpl();
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

    for (final goldSeller
        in goldPrices.domesticPrices.sortedBy((e) => e.areaName)) {
      final seller = '${goldSeller.seller}\n${goldSeller.areaName}';
      buyingPricesMap[seller] = goldSeller.buyingPrice / 1000000;
      sellingPricesMap[seller] = goldSeller.sellingPrice / 1000000;
    }

    emit(
      GoldPricesState.full(
        buyingPricesMap: buyingPricesMap,
        sellingPricesMap: sellingPricesMap,
        type: GoldPriceType.full,
      ),
    );
  }

  _updatePartialData(GoldPrices goldPrices, GoldPriceType type) async {
    Map<String, double> pricesMap = {};

    for (final goldSeller
        in goldPrices.domesticPrices.sortedBy((e) => e.areaName)) {
      final seller = '${goldSeller.seller}\n${goldSeller.areaName}';
      if (type == GoldPriceType.buying) {
        pricesMap[seller] = goldSeller.buyingPrice / 1000000;
      } else if (type == GoldPriceType.selling) {
        pricesMap[seller] = goldSeller.sellingPrice / 1000000;
      }
    }

    emit(GoldPricesState.partial(pricesMap: pricesMap, type: type));
  }
}
