import 'package:freezed_annotation/freezed_annotation.dart';

import 'bank_interest_model.dart';

part 'interest_model.freezed.dart';

part 'interest_model.g.dart';

@freezed
class InterestModel with _$InterestModel {
  const factory InterestModel({
    required Iterable<String> counterTerms,
    required Iterable<BankInterestModel> counterInterestRates,
    required Iterable<String> onlineTerms,
    required Iterable<BankInterestModel> onlineInterestRates,
  }) = _InterestModel;

  factory InterestModel.fromJson(Map<String, dynamic> json) =>
      _$InterestModelFromJson(json);
}
