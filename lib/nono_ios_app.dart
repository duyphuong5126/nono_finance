import 'package:flutter/cupertino.dart';
import 'package:nono_finance/exchange/exchange_page_ios.dart';
import 'package:nono_finance/gasoline/gas_prices_page_ios.dart';
import 'package:nono_finance/gold/gold_prices_page_ios.dart';

import 'crawler/finance_data_crawler.dart';
import 'home/home_page_ios.dart';
import 'shared/constants.dart';

class NonoIOSApp extends StatelessWidget {
  const NonoIOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      onGenerateRoute: (settings) => CupertinoPageRoute(
        settings: settings,
        builder: (context) {
          switch (settings.name) {
            case exchangeRoute:
              return const ExchangePageIOS();
            case goldPricesRoute:
              return const GoldPricesPageIOS();
            case gasPricesRoute:
              return const GasPricesPageIOS();
            default:
              throw Exception('No route found for ${settings.name}');
          }
        },
      ),
      home: const Stack(children: [FinanceDataCrawler(), HomePageIOS()]),
    );
  }
}
