import 'package:flutter/material.dart';

import '../domain/entity/currency.dart';

class ExchangePageAndroid extends StatelessWidget {
  const ExchangePageAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = ModalRoute.of(context)?.settings.arguments as Currency?;
    return Scaffold(
      appBar: AppBar(
        title: Text(currency?.defaultName ?? ''),
      ),
    );
  }
}
