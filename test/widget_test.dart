// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nono_finance/crawler/script/interest_crawling_script.dart';
import 'package:nono_finance/shared/constants.dart';

void main() {
  test('Generate crawling scripts', () {
    final file = File('../nono_finance/assets/script/crawling_scripts.json');
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    final Map<String, dynamic> json = {};
    json[interestCrawlingScriptKey] = getInterestScript;
    file.writeAsStringSync(jsonEncode(json));
  });
}
