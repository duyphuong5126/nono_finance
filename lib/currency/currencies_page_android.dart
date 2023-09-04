import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nono_finance/currency/currencies_cubit.dart';
import 'package:nono_finance/currency/currency_list_skeleton.dart';
import 'package:nono_finance/currency/currency_list_state.dart';

import '../domain/entity/currency.dart';
import '../shared/constants.dart';
import '../shared/dimens.dart';

class CurrenciesPageAndroid extends StatelessWidget {
  const CurrenciesPageAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CurrencyListCubit()..init(),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<CurrencyListCubit, CurrencyListState>(
            builder: (context, state) {
              final text = switch (state) {
                CurrencyListInitialState() => 'Đang tải...',
                CurrencyListInitializedState() => 'Tỉ giá',
              };
              return Text(text);
            },
          ),
        ),
        body: BlocBuilder<CurrencyListCubit, CurrencyListState>(
          builder: (context, state) {
            return switch (state) {
              CurrencyListInitialState() => CurrencyListSkeleton(
                  startColor: Colors.grey[800]!,
                  endColor: Colors.grey[400]!,
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
    final textTheme = Theme.of(context).textTheme;
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      edgeOffset: 0.0,
      onRefresh: () async {
        return context
            .read<CurrencyListCubit>()
            .init()
            .then((value) => Future.delayed(const Duration(seconds: 2)));
      },
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final currency = currencyList.elementAt(index);
          return ListTile(
            onTap: () {
              Navigator.pushNamed(context, exchangeRoute, arguments: currency);
            },
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(currency.code.toUpperCase(), style: textTheme.bodyMedium),
                const SizedBox(height: spaceHalf),
                Text(
                  currency.defaultName,
                  style: textTheme.bodySmall,
                  maxLines: 2,
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: spaceHalf);
        },
        itemCount: currencyList.length,
      ),
    );
  }
}
