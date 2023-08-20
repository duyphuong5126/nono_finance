import 'dart:io';

import 'package:webview_flutter/webview_flutter.dart';

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

final crawlerControllers = [interestCrawler];

final Map<WebViewController, List<Function(Map<String, dynamic>)>>
    callbackByCrawlerMap = {interestCrawler: []};

final Map<WebViewController, String> scriptByCrawlerMap = {
  interestCrawler: getInterestScript
};

final Map<WebViewController, String> urlByCrawlerMap = {
  interestCrawler: 'https://webgia.com/lai-suat/'
};
