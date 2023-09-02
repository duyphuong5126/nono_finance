import 'package:flutter/material.dart';

import '../domain/entity/currency.dart';

class ExchangePageAndroid extends StatelessWidget {
  const ExchangePageAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = ModalRoute.of(context)?.settings.arguments as Currency?;
    String pageTitle = '';
    if (currency != null) {
      pageTitle += '${currency.defaultName} (${currency.code.toUpperCase()})';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle, maxLines: 2),
      ),
    );
  }
}
