import 'dart:developer';

import 'package:nono_finance/infrastructure/interest_repository.dart';
import 'package:nono_finance/interest/interest_state.dart';
import 'package:nono_finance/interest/interest_type.dart';
import 'package:nono_finance/shared/nono_cubit.dart';

import '../domain/entity/bank_interest.dart';

class InterestCubit extends NonoCubit<InterestState> {
  InterestCubit() : super(const InterestState.initial());

  final InterestRepository _repository = InterestRepositoryImpl();

  Iterable<BankInterest>? interestRates;

  @override
  init() async {
    try {
      final result = await _repository.getBankInterestList();
      final interestRatesByGroup = {
        for (var bankIndex = 0; bankIndex < result.length; bankIndex++)
          result.elementAt(bankIndex).name:
              result.elementAt(bankIndex).counterInterestByTermMap.map(
                    (key, value) => key > 0
                        ? MapEntry('$key tháng', value)
                        : MapEntry('KKH', value),
                  )
      };
      emit(
        InterestState.initialized(
          type: InterestType.counterByBank,
          interestRatesByGroup: interestRatesByGroup,
        ),
      );
    } on Exception catch (e) {
      log('InterestCubit>>> initialization failed by $e');
    }
  }
}
