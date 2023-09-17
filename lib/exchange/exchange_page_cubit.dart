import 'dart:collection';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:nono_finance/domain/entity/bank.dart';
import 'package:nono_finance/domain/entity/bank_exchange.dart';
import 'package:nono_finance/domain/entity/currency.dart';
import 'package:nono_finance/exchange/exchange_type.dart';
import 'package:nono_finance/exchange/exchange_page_state.dart';
import 'package:nono_finance/infrastructure/exchange_repository_impl.dart';
import 'package:nono_finance/shared/extension/data_ext.dart';
import 'package:nono_finance/shared/nono_cubit.dart';

import '../domain/repository/exchange_repository.dart';

class ExchangePageCubit extends NonoCubit<ExchangePageState> {
  ExchangePageCubit(this.sourceCurrency)
      : super(const ExchangePageState.initial());

  final Currency sourceCurrency;

  final ExchangeRepository _repository = ExchangeRepositoryImpl();

  BankExchange? _bankExchange;

  @override
  init() async {
    const exchangeType = ExchangeType.bank; //Todo: load from storage
    try {
      _bankExchange = await _repository.getBankExchangeList(sourceCurrency);
      changeType(exchangeType);
    } on Exception catch (e) {
      log('Exchange>>> failed to load exchange data with error', error: e);
      emit(const ExchangePageState.failure(type: exchangeType));
    }
  }

  refresh() async {
    ExchangeType? exchangeType;
    final currentState = state;
    if (currentState is ExchangePageInitializedState) {
      exchangeType = currentState.type;
    } else if (currentState is ExchangePageFailureState) {
      exchangeType = currentState.type;
    }
    if (exchangeType != null) {
      try {
        _bankExchange = await _repository.getBankExchangeList(sourceCurrency);
        changeType(exchangeType);
      } on Exception catch (e) {
        log('Exchange>>> failed to load exchange data with error', error: e);
        emit(ExchangePageState.failure(type: exchangeType));
      }
    }
  }

  changeType(ExchangeType type) async {
    final bankExchange = _bankExchange;
    if (bankExchange != null) {
      final Map<String, Map<String, double>> exchangesByGroup;
      switch (type) {
        case ExchangeType.bank:
          exchangesByGroup = await compute(
            _groupExchangeDataByBank,
            bankExchange,
          );
          break;
        default:
          exchangesByGroup = await compute(
            _groupExchangeDataByTransactionType,
            bankExchange,
          );
          break;
      }
      emit(
        ExchangePageState.initialized(
          exchangesByGroup: exchangesByGroup,
          fromCurrency: sourceCurrency,
          type: type,
          updatedAt: bankExchange.updatedTime,
        ),
      );
    }
  }

  static Map<String, Map<String, double>> _groupExchangeDataByBank(
    BankExchange data,
  ) {
    Map<String, Map<String, double>> exchangesByGroup = {};
    Set<Bank> banks = HashSet();
    banks.addAll(data.buyCashMap.keys);
    banks.addAll(data.buyTransferMap.keys);
    banks.addAll(data.sellCashMap.keys);
    banks.addAll(data.sellTransferMap.keys);
    for (final bank in banks) {
      Map<String, double> exchanges = {};
      exchanges['Mua tiền mặt'] = data.buyCashMap[bank] ?? -1.0;
      exchanges['Mua chuyển khoản'] = data.buyTransferMap[bank] ?? -1.0;
      exchanges['Bán tiền mặt'] = data.sellCashMap[bank] ?? -1.0;
      exchanges['Bán chuyển khoản'] = data.sellTransferMap[bank] ?? -1.0;
      exchangesByGroup[bank.name.capitalize()] = exchanges;
    }
    return exchangesByGroup;
  }

  static Map<String, Map<String, double>> _groupExchangeDataByTransactionType(
    BankExchange data,
  ) {
    Map<String, Map<String, double>> exchangesByGroup = {};
    exchangesByGroup['Mua tiền mặt'] = data.buyCashMap.map(
      (key, value) => MapEntry(
        key.name.capitalize(),
        value,
      ),
    );
    exchangesByGroup['Mua chuyển khoản'] = data.buyTransferMap.map(
      (key, value) => MapEntry(
        key.name.capitalize(),
        value,
      ),
    );
    exchangesByGroup['Bán tiền mặt'] = data.sellCashMap.map(
      (key, value) => MapEntry(
        key.name.capitalize(),
        value,
      ),
    );
    exchangesByGroup['Bán chuyển khoản'] = data.sellTransferMap.map(
      (key, value) => MapEntry(
        key.name.capitalize(),
        value,
      ),
    );
    return exchangesByGroup;
  }
}
