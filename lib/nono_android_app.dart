import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nono_finance/home/home_page_android.dart';

import 'crawler/finance_data_crawler.dart';
import 'shared/colors.dart';

class NonoAndroidApp extends StatelessWidget {
  const NonoAndroidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Stack(
        children: [
          FinanceDataCrawler(),
          HomePageAndroid(),
        ],
      ),
      theme: _buildLightTheme(),
    );
  }

  ThemeData _buildLightTheme() {
    final baseTheme = ThemeData(brightness: Brightness.light);
    final textTheme = GoogleFonts.mulishTextTheme(baseTheme.textTheme);
    return baseTheme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: appBackground,
        elevation: 0.0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: appBackground,
        elevation: 0.0,
      ),
      textTheme: textTheme,
      scaffoldBackgroundColor: appBackground,
      colorScheme: baseTheme.colorScheme.copyWith(
        onPrimary: Colors.black,
      ),
    );
  }
}
