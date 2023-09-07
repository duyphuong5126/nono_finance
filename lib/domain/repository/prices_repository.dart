import '../entity/gold_prices.dart';

abstract class PricesRepository {
  Future<GoldPrices> getGoldPrices();
}
