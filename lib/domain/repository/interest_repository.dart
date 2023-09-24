import '../entity/bank_interests.dart';

abstract class InterestRepository {
  Future<BankInterests> getBankInterestList();
}
