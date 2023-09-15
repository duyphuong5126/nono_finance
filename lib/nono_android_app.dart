import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nono_finance/exchange/exchange_page_android.dart';
import 'package:nono_finance/gold/gold_prices_page_android.dart';
import 'package:nono_finance/home/home_page_android.dart';

import 'crawler/finance_data_crawler.dart';
import 'gasoline/gas_prices_page_android.dart';
import 'shared/colors.dart';
import 'shared/constants.dart';

class NonoAndroidApp extends StatelessWidget {
  const NonoAndroidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) => PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          switch (settings.name) {
            case exchangeRoute:
              return const ExchangePageAndroid();
            case goldPricesRoute:
              return const GoldPricesPageAndroid();
            case gasPricesRoute:
              return const GasPricesPageAndroid();
            default:
              throw Exception('No route found for ${settings.name}');
          }
        },
        settings: settings,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
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
    final appbarTextTheme = GoogleFonts.exo2TextTheme(baseTheme.textTheme);
    return baseTheme.copyWith(
      appBarTheme: AppBarTheme(
        titleTextStyle: appbarTextTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        backgroundColor: appBackground,
        elevation: 0.0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: appBackground,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: appBackground,
        elevation: 0.0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      ),
      textTheme: textTheme,
      scaffoldBackgroundColor: appBackground,
      colorScheme: baseTheme.colorScheme.copyWith(
        onPrimary: Colors.black,
      ),
    );
  }
}
