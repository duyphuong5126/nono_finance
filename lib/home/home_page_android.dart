import 'package:flutter/material.dart';
import 'package:nono_finance/currency/currencies_page_android.dart';
import 'package:nono_finance/interest/interest_page_android.dart';
import 'package:nono_finance/shared/widget/nono_icon.dart';

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
    const selectedColor = Colors.black;
    final unselectedColor = Colors.grey[500];
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [InterestPageAndroid(), CurrenciesPageAndroid()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: NonoIcon(
              'assets/icon/ic_savings.svg',
              width: space2,
              height: space2,
              color: _selectedIndex == 0 ? selectedColor : unselectedColor,
            ),
            label: 'Lãi suất',
            tooltip: 'Lãi suất',
          ),
          BottomNavigationBarItem(
            icon: NonoIcon(
              'assets/icon/ic_exchange.svg',
              width: space2,
              height: space2,
              color: _selectedIndex == 1 ? selectedColor : unselectedColor,
            ),
            label: 'Tỉ giá',
            tooltip: 'Tỉ giá',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[500],
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
}
