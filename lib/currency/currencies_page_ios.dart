import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entity/currency.dart';
import '../shared/constants.dart';
import '../shared/dimens.dart';
import '../shared/widget/loading_body.dart';
import 'currencies_cubit.dart';
import 'currency_list_state.dart';

class CurrenciesPageIOS extends StatelessWidget {
  const CurrenciesPageIOS({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CurrencyListCubit()..init(),
      child: BlocBuilder<CurrencyListCubit, CurrencyListState>(
        builder: (context, state) {
          return _CurrencyListPage(state);
        },
      ),
    );
  }
}

class _CurrencyListPage extends StatelessWidget {
  const _CurrencyListPage(this.state);

  final CurrencyListState state;

  @override
  Widget build(BuildContext context) {
    final currentState = state;
    final text = switch (state) {
      CurrencyListInitialState() => 'Đang tải...',
      CurrencyListInitializedState() => 'Tỉ giá',
    };
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(text),
      ),
      child: switch (currentState) {
        CurrencyListInitialState() => const LoadingBody(),
        CurrencyListInitializedState() => _CurrencyList(
            currencyList: currentState.currencyList,
          ),
      },
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
