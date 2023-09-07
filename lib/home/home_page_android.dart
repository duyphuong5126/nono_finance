import 'package:flutter/material.dart';
import 'package:nono_finance/currency/currencies_page_android.dart';
import 'package:nono_finance/interest/interest_page_android.dart';
import 'package:nono_finance/shared/colors.dart';
import 'package:nono_finance/shared/widget/nono_icon.dart';

import '../gold/gold_prices_page_android.dart';
import '../shared/dimens.dart';

class HomePageAndroid extends StatefulWidget {
  const HomePageAndroid({Key? key}) : super(key: key);

  @override
  State<HomePageAndroid> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageAndroid> {
  static const int _defaultTabIndex = 0;
  int _selectedIndex = _defaultTabIndex;

  @override
  Widget build(BuildContext context) {
    final unselectedColor = Colors.grey[500];
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          InterestPageAndroid(),
          CurrenciesPageAndroid(),
          GoldPricesPageAndroid(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          _generateBarItem(
            index: 0,
            label: 'Lãi suất',
            icon: 'assets/icon/ic_savings.svg',
          ),
          _generateBarItem(
            index: 1,
            label: 'Tỉ giá',
            icon: 'assets/icon/ic_exchange.svg',
          ),
          _generateBarItem(
            index: 2,
            label: 'Giá cả',
            icon: 'assets/icon/ic_coins.svg',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: unselectedColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 14.0,
        unselectedFontSize: 14.0,
        onTap: _onTabSelected,
      ),
    );
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBarItem _generateBarItem({
    required String label,
    required String icon,
    required int index,
  }) {
    final unselectedColor = Colors.grey[500];
    return BottomNavigationBarItem(
      icon: NonoIcon(
        icon,
        width: space2,
        height: space2,
        color: _selectedIndex == index ? primaryColor : unselectedColor,
      ),
      label: label,
    );
  }
}
