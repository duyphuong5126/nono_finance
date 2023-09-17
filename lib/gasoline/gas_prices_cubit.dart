import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:nono_finance/shared/nono_cubit.dart';

import '../domain/repository/prices_repository.dart';
import '../infrastructure/prices_repository_impl.dart';
import 'gas_prices_state.dart';

class GasPricesCubit extends NonoCubit<GasPricesState> {
  GasPricesCubit() : super(const GasPricesState.initial());

  final PricesRepository _repository = PricesRepositoryImpl();
  final priceFormat = NumberFormat("#,##0.00", "en_US");

  @override
  init() async {
    try {
      final gasPrices = await _repository.getGasPrices();
      emit(
        GasPricesState.initialized(
          prices: gasPrices.domesticPrices,
          updatedAt: gasPrices.updatedAt,
        ),
      );
    } on Exception catch (error) {
      log('GasPricesCubit>>> failed to get gas prices with error $error');
      emit(const GasPricesState.failure());
    }
  }

  refresh() {}
}
