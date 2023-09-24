import 'package:freezed_annotation/freezed_annotation.dart';

import 'bank_interest.dart';

part 'bank_interests.freezed.dart';

@freezed
class BankInterests with _$BankInterests {
  const factory BankInterests({
    required Iterable<BankInterest> interestList,
    required DateTime updatedTime,
  }) = _BankInterests;
}
