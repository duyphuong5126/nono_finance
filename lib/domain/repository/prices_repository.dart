import '../entity/gas_prices.dart';
import '../entity/gold_prices.dart';

abstract class PricesRepository {
  Future<GoldPrices> getGoldPrices();

  Future<GasPrices> getGasPrices();
}
