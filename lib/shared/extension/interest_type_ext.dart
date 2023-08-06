import '../../interest/interest_type.dart';

extension InterestTypeExt on InterestType {
  String get label => switch (this) {
        InterestType.counterByBank => 'Lãi suất tại quầy theo ngân hàng',
        InterestType.counterByTerm => 'Lãi suất tại quầy theo kỳ hạn',
        InterestType.onlineByBank => 'Lãi suất online theo ngân hàng',
        InterestType.onlineByTerm => 'Lãi suất online theo kỳ hạn'
      };
}
