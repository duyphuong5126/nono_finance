import 'package:freezed_annotation/freezed_annotation.dart';

part 'bank.freezed.dart';

@freezed
class Bank with _$Bank {
  const factory Bank({
    required String name,
    required String code,
  }) = _Bank;
}
