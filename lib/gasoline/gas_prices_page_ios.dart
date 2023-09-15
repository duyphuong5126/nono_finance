import 'package:flutter/cupertino.dart';

class GasPricesPageIOS extends StatelessWidget {
  const GasPricesPageIOS({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Gas prices'),
      ),
      child: SafeArea(
        child: Center(
          child: Text('Gas prices body', maxLines: 2),
        ),
      ),
    );
  }
}
