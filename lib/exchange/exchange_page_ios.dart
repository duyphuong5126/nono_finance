import 'package:flutter/cupertino.dart';

class ExchangePageIOS extends StatelessWidget {
  const ExchangePageIOS({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Tỉ giá'),
      ),
      child: SafeArea(
        child: Center(
          child: Text('Tỉ giá'),
        ),
      ),
    );
  }
}
