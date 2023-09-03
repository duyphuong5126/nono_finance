import 'dart:convert';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:nono_finance/crawler/crawlers.dart';
import 'package:nono_finance/util.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FinanceDataCrawler extends StatefulWidget {
  const FinanceDataCrawler({super.key});

  @override
  State<FinanceDataCrawler> createState() => _FinanceDataCrawlerState();
}

class _FinanceDataCrawlerState extends State<FinanceDataCrawler> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    for (final entry in callbackByCrawlerMap.entries) {
      final controller = entry.key;
      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              _updateLoadingStatus(true);
            },
            onPageFinished: (url) async {
              _updateLoadingStatus(false);
              final script = scriptByCrawlerMap[controller];
              if (script != null) {
                try {
                  final data = (await controller.getTextByJavascript(script))
                      .replaceAll('\\"', '"')
                      .replaceAll('<html>', '')
                      .replaceAll('</html>', '');
                  log('Crawler>>> parsed data from url $url:\n$data');
                  final jsonData = jsonDecode(data);
                  if (jsonData != null) {
                    for (final callback in entry.value) {
                      callback(jsonData);
                    }
                  } else {
                    _respondWithError(
                      controller,
                      Exception('Could not parse data from $url'),
                    );
                  }
                } on Exception catch (e) {
                  log('Crawler>>> error parsing data from url $url:', error: e);
                  _respondWithError(controller, e);
                }
              } else {
                log('Crawler>>> no script found for url $url');
                _respondWithError(
                  controller,
                  Exception('No script found for url $url'),
                );
              }
            },
            onWebResourceError: (error) {
              _updateLoadingStatus(false);
              log('Crawler>>> onWebResourceError', error: error);
              _respondWithError(
                controller,
                Exception('onWebResourceError - $error'),
              );
            },
          ),
        );
    }
  }

  _respondWithError(WebViewController controller, Exception exception) {
    errorCallbackByCrawlerMap[controller]?.forEach((callback) {
      callback(exception);
    });
  }

  _updateLoadingStatus(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ...crawlerControllers.map(
          (controller) => WebViewWidget(controller: controller),
        ),
        Container(
          constraints: const BoxConstraints.expand(),
          color: const Color.fromRGBO(255, 255, 255, 1.0),
          child: Center(
            child: Text(_loading ? 'Loading' : 'Finished'),
          ),
        )
      ],
    );
  }
}
