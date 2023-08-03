import 'package:freezed_annotation/freezed_annotation.dart';

part 'interest_state.freezed.dart';

@freezed
sealed class InterestState with _$InterestState {
  @Implements<InterestInitialState>()
  const factory InterestState.initial() = Initial;

  @Implements<InterestInitializedState>()
  const factory InterestState.initialized({
    required Map<String, Map<String, double>> counterInterestByGroup,
    required Map<String, Map<String, double>> onlineInterestByGroup,
  }) = Initialized;
}

abstract class InterestInitialState implements InterestState {}

abstract class InterestInitializedState implements InterestState {
  Map<String, Map<String, double>> get counterInterestByGroup;

  Map<String, Map<String, double>> get onlineInterestByGroup;
}
