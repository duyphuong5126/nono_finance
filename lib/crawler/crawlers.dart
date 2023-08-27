import 'dart:io';

import 'package:webview_flutter/webview_flutter.dart';

import 'script/currency_crawling_script.dart';
import 'script/interest_crawling_script.dart';

WebViewController _generateWebViewController() {
  return Platform.isAndroid
      ? (WebViewController()
        ..setNavigationDelegate(
          NavigationDelegate(),
        ))
      : WebViewController();
}

final interestCrawler = _generateWebViewController();
final currenciesCrawler = _generateWebViewController();

final crawlerControllers = [interestCrawler, currenciesCrawler];

final Map<WebViewController, List<Function(Map<String, dynamic>)>>
    callbackByCrawlerMap = {
  interestCrawler: [],
  currenciesCrawler: [],
};

final Map<WebViewController, String> scriptByCrawlerMap = {
  interestCrawler: getInterestScript,
  currenciesCrawler: getCurrenciesScript,
};

final Map<WebViewController, String> urlByCrawlerMap = {
  interestCrawler: 'https://webgia.com/lai-suat/',
  currenciesCrawler: 'https://webgia.com/ngoai-te/usd/'
};
