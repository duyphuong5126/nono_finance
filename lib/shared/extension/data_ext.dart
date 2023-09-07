import 'package:nono_finance/domain/entity/product_type.dart';
import 'package:nono_finance/exchange/exchange_type.dart';

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
}
