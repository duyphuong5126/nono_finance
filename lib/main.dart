import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nono_finance/app.dart';
import 'package:nono_finance/crawler/crawlers.dart';
import 'package:nono_finance/shared/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kDebugMode) {
    try {
      final scriptResponse = await get(Uri.parse(interestCrawlingScriptUrl));
      if (scriptResponse.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(scriptResponse.body);
        scriptByCrawlerMap[interestCrawler] = body[interestCrawlingScriptKey];
      }
    } on Exception catch (e) {
      log('Scripts crawling failed with error $e');
    }
  }
  runApp(const NonoFinanceApp());
}
