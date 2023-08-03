import 'dart:developer';

import 'package:nono_finance/infrastructure/interest_repository.dart';
import 'package:nono_finance/interest/interest_state.dart';
import 'package:nono_finance/shared/nono_cubit.dart';

class InterestCubit extends NonoCubit<InterestState> {
  InterestCubit() : super(const InterestState.initial());

  final InterestRepository _repository = InterestRepositoryImpl();

  @override
  init() async {
    try {
      final result = await _repository.getBankInterestList();
      final counterInterestByGroup = {
        for (var bankIndex = 0; bankIndex < result.length; bankIndex++)
          result.elementAt(bankIndex).name:
              result.elementAt(bankIndex).counterInterestByTermMap.map(
                    (key, value) => key > 0
                        ? MapEntry('$key tháng', value)
                        : MapEntry('KKH', value),
                  )
      };
      final onlineRateByGroup = {
        for (var bankIndex = 0; bankIndex < result.length; bankIndex++)
          result.elementAt(bankIndex).name:
              result.elementAt(bankIndex).onlineInterestByTermMap.map(
                    (key, value) => key > 0
                        ? MapEntry('$key months', value)
                        : MapEntry('No term', value),
                  )
      };
      emit(
        InterestState.initialized(
          counterInterestByGroup: counterInterestByGroup,
          onlineInterestByGroup: onlineRateByGroup,
        ),
      );
    } on Exception catch (e) {
      log('InterestCubit>>> initialization failed by $e');
    }
  }
}
