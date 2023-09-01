import 'package:flutter/cupertino.dart';
import 'package:nono_finance/domain/entity/currency.dart';

class ExchangePageIOS extends StatelessWidget {
  const ExchangePageIOS({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = ModalRoute.of(context)?.settings.arguments as Currency?;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(currency?.defaultName ?? ''),
      ),
      child: const Center(),
    );
  }
}
