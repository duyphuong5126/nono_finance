import 'package:webview_flutter/webview_flutter.dart';

import 'script/interest_crawling_script.dart';

final interestCrawler = WebViewController();

final crawlerControllers = [interestCrawler];

final Map<WebViewController, List<Function(Map<String, dynamic>)>>
    callbackByCrawlerMap = {interestCrawler: []};

final Map<WebViewController, String> scriptByCrawlerMap = {
  interestCrawler: getInterestScript
};

final Map<WebViewController, String> urlByCrawlerMap = {
  interestCrawler: 'https://webgia.com/lai-suat/'
};
