import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nono_finance/interest/interest_type.dart';

part 'interest_state.freezed.dart';

@freezed
sealed class InterestState with _$InterestState {
  @Implements<InterestInitialState>()
  const factory InterestState.initial() = Initial;

  @Implements<InterestInitializedState>()
  const factory InterestState.initialized({
    required InterestType type,
    required Map<String, Map<String, double>> interestRatesByGroup,
  }) = Initialized;
}

abstract class InterestInitialState implements InterestState {}

abstract class InterestInitializedState implements InterestState {
  Map<String, Map<String, double>> get interestRatesByGroup;

  InterestType get type;
}
