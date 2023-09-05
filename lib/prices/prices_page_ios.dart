import 'package:flutter/cupertino.dart';

class PricesPageIOS extends StatelessWidget {
  const PricesPageIOS({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Giá cả'),
      ),
      child: Center(
        child: Text('Giá cả'),
      ),
    );
  }
}
