import 'package:flutter/cupertino.dart';
import 'package:nono_finance/currency/currencies_page_ios.dart';
import 'package:nono_finance/interest/interest_page_ios.dart';

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
    const unselectedColor = CupertinoColors.inactiveGray;
    const List<Widget> tabs = [
      InterestPageIOS(),
      CurrenciesPageIOS(),
    ];

    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          activeColor: primaryColor,
          inactiveColor: unselectedColor,
          items: [
            BottomNavigationBarItem(
              icon: NonoIcon(
                'assets/icon/ic_savings.svg',
                width: space4,
                height: space4,
                color: _selectedIndex == 0 ? primaryColor : unselectedColor,
              ),
              label: 'Lãi suất',
              tooltip: 'Lãi suất',
            ),
            BottomNavigationBarItem(
              icon: NonoIcon(
                'assets/icon/ic_exchange.svg',
                width: space4,
                height: space4,
                color: _selectedIndex == 1 ? primaryColor : unselectedColor,
              ),
              label: 'Tỉ giá',
              tooltip: 'Tỉ giá',
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
}
