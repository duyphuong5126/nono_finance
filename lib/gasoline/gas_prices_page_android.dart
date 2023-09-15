import 'package:flutter/material.dart';

class GasPricesPageAndroid extends StatelessWidget {
  const GasPricesPageAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gas prices', maxLines: 2),
      ),
      body: const SafeArea(
        child: Center(
          child: Text('Gas prices body', maxLines: 2),
        ),
      ),
    );
  }
}
