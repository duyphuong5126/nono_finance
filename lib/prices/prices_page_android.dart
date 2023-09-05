import 'package:flutter/material.dart';

class PricesPageAndroid extends StatelessWidget {
  const PricesPageAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giá cả'),
      ),
      body: const Center(
        child: Text('Giá cả'),
      ),
    );
  }
}
