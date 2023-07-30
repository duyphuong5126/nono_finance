import 'package:freezed_annotation/freezed_annotation.dart';

part 'bank_interest_model.freezed.dart';

part 'bank_interest_model.g.dart';

@freezed
class BankInterestModel with _$BankInterestModel {
  const factory BankInterestModel({
    required String bankName,
    required Iterable<String> interestRates,
  }) = _BankInterestModel;

  factory BankInterestModel.fromJson(Map<String, dynamic> json) =>
      _$BankInterestModelFromJson(json);
}
