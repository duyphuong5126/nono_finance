import 'dart:developer';

import 'package:nono_finance/infrastructure/exchange_repository.dart';
import 'package:nono_finance/shared/nono_cubit.dart';

import 'currency_list_state.dart';

class CurrencyListCubit extends NonoCubit<CurrencyListState> {
  CurrencyListCubit() : super(const CurrencyListState.initial());

  final ExchangeRepository _repository = ExchangeRepositoryImpl();

  @override
  init() async {
    try {
      final currencies = await _repository.getCurrencyList();
      emit(CurrencyListState.initialized(currencyList: currencies));
    } on Exception catch (e) {
      log('CurrencyListCubit>>> failed to fetch currencies with error $e');
    }
  }
}
