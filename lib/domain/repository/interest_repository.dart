import '../entity/bank_interest.dart';

abstract class InterestRepository {
  Future<Iterable<BankInterest>> getBankInterestList();
}
