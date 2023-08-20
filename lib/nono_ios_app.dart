import 'package:flutter/cupertino.dart';

import 'crawler/finance_data_crawler.dart';
import 'home/home_page_ios.dart';

class NonoIOSApp extends StatelessWidget {
  const NonoIOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      home: Stack(children: [FinanceDataCrawler(), HomePageIOS()]),
    );
  }
}
