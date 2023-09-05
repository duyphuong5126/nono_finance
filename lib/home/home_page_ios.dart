import 'package:flutter/cupertino.dart';
import 'package:nono_finance/currency/currencies_page_ios.dart';
import 'package:nono_finance/interest/interest_page_ios.dart';
import 'package:nono_finance/prices/prices_page_ios.dart';

import '../shared/colors.dart';
import '../shared/dimens.dart';
import '../shared/widget/nono_icon.dart';

class HomePageIOS extends StatefulWidget {
  const HomePageIOS({Key? key}) : super(key: key);

  @override
  State<HomePageIOS> createState() => _HomePageIOSState();
}

class _HomePageIOSState extends State<HomePageIOS> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    const List<Widget> tabs = [
      InterestPageIOS(),
      CurrenciesPageIOS(),
      PricesPageIOS(),
    ];

    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          activeColor: primaryColor,
          inactiveColor: CupertinoColors.inactiveGray,
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
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        tabBuilder: (context, int index) {
          return tabs[index];
        },
      ),
    );
  }

  BottomNavigationBarItem _generateBarItem({
    required String label,
    required String icon,
    required int index,
  }) {
    const unselectedColor = CupertinoColors.inactiveGray;
    return BottomNavigationBarItem(
      icon: NonoIcon(
        icon,
        width: space4,
        height: space4,
        color: _selectedIndex == index ? primaryColor : unselectedColor,
      ),
      label: label,
    );
  }
}
