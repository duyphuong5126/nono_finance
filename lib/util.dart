import 'package:webview_flutter/webview_flutter.dart';

extension WebViewControllerExtension on WebViewController {
  Future<String> getTextByJavascript(String script) {
    return runJavaScriptReturningResult(script).then(
      (json) => json
          .toString()
          .replaceAll("\"\\u003Chtml>", "")
          .replaceAll("\\u003C/html>\"", ""),
    );
  }

  void loadUrl(String url) {
    loadRequest(Uri.parse(url));
  }
}
