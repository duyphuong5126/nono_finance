import 'package:flutter/material.dart';

class ExchangePageAndroid extends StatelessWidget {
  const ExchangePageAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tỉ giá'),
      ),
      body: const Center(
        child: Text('Tỉ giá'),
      ),
    );
  }
}
