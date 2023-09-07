import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nono_finance/shared/colors.dart';
import 'package:nono_finance/shared/widget/chart/bar_chart/nono_horizontal_multi_bar_chart.dart';
import 'package:nono_finance/shared/widget/chart/bar_chart/double_bar_configs.dart';

import '../shared/dimens.dart';
import '../shared/widget/bar_chart_list_skeleton.dart';
import '../shared/widget/error_body.dart';
import 'gold_prices_cubit.dart';
import 'gold_prices_state.dart';

class GoldPricesPageAndroid extends StatelessWidget {
  const GoldPricesPageAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GoldPricesPageCubit()..init(),
      child: BlocBuilder<GoldPricesPageCubit, GoldPricesState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Giá vàng'),
            ),
            body: switch (state) {
              GoldPricesInitialState() => BarChartListSkeleton(
                  startColor: Colors.grey[800]!,
                  endColor: Colors.grey[400]!,
                ),
              GoldPricesInitializedState() => _InitializedBody(state),
              GoldPricesFailureState() => const _ErrorBody(),
            },
          );
        },
      ),
    );
  }
}

class _InitializedBody extends StatelessWidget {
  const _InitializedBody(this.state);

  final GoldPricesInitializedState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      edgeOffset: 0.0,
      onRefresh: () async {
        return context
            .read<GoldPricesPageCubit>()
            .refresh()
            .then((value) => Future.delayed(const Duration(seconds: 2)));
      },
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: space1),
            child: Text('Đơn vị: triệu đồng', style: textTheme.titleMedium),
          ),
          NonoHorizontalMultiBarChart(
            height: MediaQuery.of(context).size.height * 3,
            axisColor: Colors.black,
            firstBarConfigsList: state.buyingPricesMap.entries
                .map((e) => SingleBarConfigs(xLabel: e.key, yValue: e.value))
                .toList(),
            secondBarConfigsList: state.sellingPricesMap.entries
                .map((e) => SingleBarConfigs(xLabel: e.key, yValue: e.value))
                .toList(),
            firstBarColor: brandNormalColor,
            secondBarColor: brandPositiveColor,
            firstBarLabel: 'Giá mua',
            secondBarLabel: 'Giá bán',
            yValueFormat: NumberFormat("#,##0.00", "en_US"),
            valueFormat: NumberFormat("#,##0.00", "en_US"),
          )
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      edgeOffset: 0.0,
      onRefresh: () async {
        return context
            .read<GoldPricesPageCubit>()
            .refresh()
            .then((value) => Future.delayed(const Duration(seconds: 2)));
      },
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: space4),
            child: ErrorBody(
              errorMessage: 'Không tìm thấy thông tin giá vàng',
              errorTextStyle: textTheme.titleMedium,
            ),
          )
        ],
      ),
    );
  }
}
