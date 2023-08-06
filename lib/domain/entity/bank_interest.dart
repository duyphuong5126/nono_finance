import 'package:freezed_annotation/freezed_annotation.dart';

part 'bank_interest.freezed.dart';

@freezed
class BankInterest with _$BankInterest {
  const factory BankInterest({
    required String bankName,
    required Map<int, double> counterInterestByTermMap,
    required Map<int, double> onlineInterestByTermMap,
  }) = _BankInterest;
}
