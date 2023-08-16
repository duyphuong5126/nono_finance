import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nono_finance/crawler/finance_data_crawler.dart';
import 'package:nono_finance/interest/interest_page_android.dart';
import 'package:nono_finance/interest/interest_page_ios.dart';

class NonoFinanceApp extends StatelessWidget {
  const NonoFinanceApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? MaterialApp(
            home: _buildBase(const InterestPageAndroid()),
          )
        : CupertinoApp(
            home: _buildBase(const InterestPageIOS()),
          );
  }

  Widget _buildBase(Widget child) {
    return Stack(children: [const FinanceDataCrawler(), child]);
  }
}
