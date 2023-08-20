import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nono_finance/nono_android_app.dart';
import 'package:nono_finance/nono_ios_app.dart';

class NonoFinanceApp extends StatelessWidget {
  const NonoFinanceApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid ? const NonoAndroidApp() : const NonoIOSApp();
  }
}
