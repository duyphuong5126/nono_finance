import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nono_finance/app.dart';
import 'package:nono_finance/crawler/crawlers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final interestScript =
      await rootBundle.loadString('assets/script/interest_crawling.js');
  scriptByCrawlerMap[interestCrawler] = interestScript;
  runApp(const NonoFinanceApp());
}
