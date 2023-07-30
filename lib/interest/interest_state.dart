import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/entity/bank_interest.dart';

part 'interest_state.freezed.dart';

@freezed
sealed class InterestState with _$InterestState {
  @Implements<InterestInitialState>()
  const factory InterestState.initial() = Initial;

  @Implements<InterestInitializedState>()
  const factory InterestState.initialized({
    required Iterable<BankInterest> interestRatesByBank,
  }) = Initialized;
}

abstract class InterestInitialState implements InterestState {}

abstract class InterestInitializedState implements InterestState {}
