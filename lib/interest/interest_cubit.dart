import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:nono_finance/infrastructure/interest_repository.dart';
import 'package:nono_finance/interest/interest_state.dart';
import 'package:nono_finance/domain/entity/interest_type.dart';
import 'package:nono_finance/shared/nono_cubit.dart';

import '../domain/entity/bank_interest.dart';

class InterestCubit extends NonoCubit<InterestState> {
  InterestCubit() : super(const InterestState.initial());

  final InterestRepository _repository = InterestRepositoryImpl();

  @override
  init() async {
    await changeInterestType(InterestType.counterByBank);
  }

  Future<void> changeInterestType(InterestType interestType) async {
    try {
      final result = await _repository.getBankInterestList();
      final interestRatesByGroup = switch (interestType) {
        InterestType.counterByBank =>
          await (compute(_counterInterestsByBank, result)),
        InterestType.onlineByBank =>
          await (compute(_onlineInterestsByBank, result)),
        InterestType.counterByTerm =>
          await (compute(_counterInterestsByTerm, result)),
        InterestType.onlineByTerm =>
          await (compute(_onlineInterestsByTerm, result))
      };
      emit(
        InterestState.initialized(
          type: interestType,
          interestRatesByGroup: interestRatesByGroup,
        ),
      );
    } on Exception catch (e) {
      log('InterestCubit>>> initialization failed by $e');
    }
  }

  static Map<String, Map<String, double>> _counterInterestsByBank(
    Iterable<BankInterest> interests,
  ) {
    return {
      for (var bankIndex = 0; bankIndex < interests.length; bankIndex++)
        interests.elementAt(bankIndex).bankName:
            interests.elementAt(bankIndex).counterInterestByTermMap.map(
                  (key, value) => key > 0
                      ? MapEntry('$key tháng', value)
                      : MapEntry('KKH', value),
                )
    };
  }

  static Map<String, Map<String, double>> _onlineInterestsByBank(
    Iterable<BankInterest> interests,
  ) {
    return {
      for (var bankIndex = 0; bankIndex < interests.length; bankIndex++)
        interests.elementAt(bankIndex).bankName:
            interests.elementAt(bankIndex).onlineInterestByTermMap.map(
                  (key, value) => key > 0
                      ? MapEntry('$key tháng', value)
                      : MapEntry('KKH', value),
                )
    };
  }

  static Map<String, Map<String, double>> _counterInterestsByTerm(
    Iterable<BankInterest> interests,
  ) {
    final Map<String, Map<String, double>> result = {};
    for (var bankIndex = 0; bankIndex < interests.length; bankIndex++) {
      final bankInterest = interests.elementAt(bankIndex);
      for (final interest in bankInterest.counterInterestByTermMap.entries) {
        final term =
            interest.key > 0 ? '${interest.key} tháng' : 'Không kỳ hạn';
        if (!result.containsKey(term)) {
          result[term] = {};
        }
        result[term]![bankInterest.bankName] = interest.value;
      }
    }
    return result;
  }

  static Map<String, Map<String, double>> _onlineInterestsByTerm(
    Iterable<BankInterest> interests,
  ) {
    final Map<String, Map<String, double>> result = {};
    for (var bankIndex = 0; bankIndex < interests.length; bankIndex++) {
      final bankInterest = interests.elementAt(bankIndex);
      for (final interest in bankInterest.onlineInterestByTermMap.entries) {
        final term =
            interest.key > 0 ? '${interest.key} tháng' : 'Không kỳ hạn';
        if (!result.containsKey(term)) {
          result[term] = {};
        }
        result[term]![bankInterest.bankName] = interest.value;
      }
    }
    return result;
  }
}
