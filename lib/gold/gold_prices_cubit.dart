import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:nono_finance/domain/repository/prices_repository.dart';
import 'package:nono_finance/infrastructure/prices_repository_impl.dart';
import 'package:nono_finance/shared/nono_cubit.dart';

import 'gold_price_type.dart';
import 'gold_prices_state.dart';

class GoldPricesPageCubit extends NonoCubit<GoldPricesState> {
  GoldPricesPageCubit() : super(const GoldPricesState.initial());

  final PricesRepository _repository = PricesRepositoryImpl();

  @override
  init() async {
    const type = GoldPriceType.seller;
    try {
      final result = await _repository.getGoldPrices();
      Map<String, double> buyingPricesMap = {};
      Map<String, double> sellingPricesMap = {};

      for (final goldSeller
          in result.domesticPrices.sortedBy((e) => e.areaName)) {
        final seller = '${goldSeller.seller}\n${goldSeller.areaName}';
        buyingPricesMap[seller] = goldSeller.buyingPrice / 1000000;
        sellingPricesMap[seller] = goldSeller.sellingPrice / 1000000;
      }

      emit(
        GoldPricesState.initialized(
          buyingPricesMap: buyingPricesMap,
          sellingPricesMap: sellingPricesMap,
          type: type,
        ),
      );
    } on Exception catch (error) {
      log(
        'GoldPricesPageCubit>>> failed to get gold prices with error',
        error: error,
      );
      emit(const GoldPricesState.failure(type: type));
    }
  }

  refresh() async {}
}
