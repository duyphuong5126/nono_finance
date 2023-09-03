import 'dart:io';

import 'package:nono_finance/crawler/script/exchange_crawling_script.dart';
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
final exchangesCrawler = _generateWebViewController();

final crawlerControllers = [
  interestCrawler,
  currenciesCrawler,
  exchangesCrawler,
];

final Map<WebViewController, List<Function(Map<String, dynamic>)>>
    callbackByCrawlerMap = {
  interestCrawler: [],
  currenciesCrawler: [],
  exchangesCrawler: [],
};

final Map<WebViewController, List<Function(Exception exception)>>
    errorCallbackByCrawlerMap = {
  interestCrawler: [],
  currenciesCrawler: [],
  exchangesCrawler: [],
};

final Map<WebViewController, String> scriptByCrawlerMap = {
  interestCrawler: getInterestScript,
  currenciesCrawler: getCurrenciesScript,
  exchangesCrawler: getExchangesScript,
};

final Map<WebViewController, String> urlByCrawlerMap = {
  interestCrawler: 'https://webgia.com/lai-suat/',
  currenciesCrawler: 'https://webgia.com/ngoai-te/usd/'
};
