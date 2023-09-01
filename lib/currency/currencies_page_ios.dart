import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entity/currency.dart';
import '../shared/constants.dart';
import '../shared/dimens.dart';
import 'currencies_cubit.dart';
import 'currency_list_skeleton.dart';
import 'currency_list_state.dart';

class CurrenciesPageIOS extends StatelessWidget {
  const CurrenciesPageIOS({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CurrencyListCubit()..init(),
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Tỉ giá'),
        ),
        child: BlocBuilder<CurrencyListCubit, CurrencyListState>(
          builder: (context, state) {
            return switch (state) {
              CurrencyListInitialState() => const CurrencyListSkeleton(
                  startColor: CupertinoColors.systemGrey,
                  endColor: CupertinoColors.systemGrey3,
                ),
              CurrencyListInitializedState() => _CurrencyList(
                  currencyList: state.currencyList,
                ),
            };
          },
        ),
      ),
    );
  }
}

class _CurrencyList extends StatelessWidget {
  const _CurrencyList({
    required this.currencyList,
  });

  final Iterable<Currency> currencyList;

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    return ListView.separated(
      itemBuilder: (context, itemIndex) {
        if (itemIndex == 0) {
          return const SizedBox(height: spaceQuarter);
        }
        final index = itemIndex - 1;
        final currency = currencyList.elementAt(index);
        return CupertinoListTile(
          onTap: () {
            Navigator.pushNamed(context, exchangeRoute, arguments: currency);
          },
          padding: const EdgeInsets.symmetric(
            vertical: spaceHalf,
            horizontal: space1,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currency.code.toUpperCase(),
                style: textTheme.navTitleTextStyle,
              ),
              const SizedBox(height: spaceHalf),
              Text(
                currency.defaultName,
                style: textTheme.textStyle,
                maxLines: 2,
              ),
            ],
          ),
          trailing: const Icon(CupertinoIcons.chevron_right),
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: spaceHalf);
      },
      itemCount: currencyList.length + 1,
    );
  }
}
