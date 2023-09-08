import 'package:nono_finance/domain/entity/product_type.dart';
import 'package:nono_finance/exchange/exchange_type.dart';
import 'package:nono_finance/gold/gold_price_type.dart';

import '../../interest/interest_type.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension InterestTypeExt on InterestType {
  String get label => switch (this) {
        InterestType.counterByBank => 'Lãi suất tại quầy theo ngân hàng',
        InterestType.counterByTerm => 'Lãi suất tại quầy theo kỳ hạn',
        InterestType.onlineByBank => 'Lãi suất online theo ngân hàng',
        InterestType.onlineByTerm => 'Lãi suất online theo kỳ hạn'
      };
}

extension ExchangeTypeExt on ExchangeType {
  String get label => switch (this) {
        ExchangeType.bank => 'Theo ngân hàng',
        ExchangeType.transactionType => 'Theo hình thức giao dịch',
      };
}

extension ProductTypeExt on ProductType {
  String get label => switch (this) {
        ProductType.gold => 'Giá vàng',
        ProductType.gas => 'Giá xăng',
      };

  String get iconPath => switch (this) {
        ProductType.gold => 'assets/icon/ic_gold.svg',
        ProductType.gas => 'assets/icon/ic_gas.svg',
      };
}

extension GoldPriceTypeExt on GoldPriceType {
  String get label => switch (this) {
        GoldPriceType.full => 'Giá đầy đủ',
        GoldPriceType.buying => 'Giá mua',
        GoldPriceType.selling => 'Giá bán',
      };

  String get title => switch (this) {
        GoldPriceType.full => 'Giá vàng',
        GoldPriceType.buying => 'Giá mua vàng',
        GoldPriceType.selling => 'Giá bán vàng',
      };
}
