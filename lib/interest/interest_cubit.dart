import 'package:nono_finance/infrastructure/interest_repository.dart';
import 'package:nono_finance/interest/interest_state.dart';
import 'package:nono_finance/shared/nono_cubit.dart';

class InterestCubit extends NonoCubit<InterestState> {
  InterestCubit() : super(const InterestState.initial());

  final InterestRepository _repository = InterestRepositoryImpl();

  @override
  init() async {
    final result = await _repository.getBankInterestList();
    emit(InterestState.initialized(interestRatesByBank: result));
  }
}
