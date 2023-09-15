import 'dart:developer';

import 'package:nono_finance/infrastructure/exchange_repository_impl.dart';
import 'package:nono_finance/shared/nono_cubit.dart';

import '../domain/repository/exchange_repository.dart';
import 'currency_list_state.dart';

class CurrencyListCubit extends NonoCubit<CurrencyListState> {
  CurrencyListCubit() : super(const CurrencyListState.initial());

  final ExchangeRepository _repository = ExchangeRepositoryImpl();

  @override
  init() async {
    await refresh();
  }

  Future<void> refresh() async {
    try {
      final currenciesResult = await _repository.getCurrencyList();
      emit(
        CurrencyListState.initialized(
          currencyList: currenciesResult.currencyList,
        ),
      );
    } on Exception catch (e) {
      log('CurrencyListCubit>>> failed to fetch currencies with error $e');
    }
  }
}
