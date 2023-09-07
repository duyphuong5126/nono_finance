import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../shared/colors.dart';
import '../shared/dimens.dart';
import '../shared/widget/bar_chart_list_skeleton.dart';
import '../shared/widget/chart/bar_chart/double_bar_configs.dart';
import '../shared/widget/chart/bar_chart/nono_horizontal_multi_bar_chart.dart';
import '../shared/widget/error_body.dart';
import 'gold_prices_cubit.dart';
import 'gold_prices_state.dart';

class GoldPricesPageIOS extends StatelessWidget {
  const GoldPricesPageIOS({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GoldPricesPageCubit()..init(),
      child: BlocBuilder<GoldPricesPageCubit, GoldPricesState>(
        builder: (context, state) {
          return CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text('Giá vàng'),
            ),
            child: switch (state) {
              GoldPricesInitialState() => const BarChartListSkeleton(
                  startColor: CupertinoColors.systemGrey,
                  endColor: CupertinoColors.systemGrey4,
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
    final textTheme = CupertinoTheme.of(context).textTheme;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () {
            return context
                .read<GoldPricesPageCubit>()
                .refresh()
                .then((value) => Future.delayed(const Duration(seconds: 2)));
          },
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: 2,
            (context, itemIndex) {
              if (itemIndex == 0) {
                return Padding(
                  padding: const EdgeInsets.only(left: space1, top: space8),
                  child: Text(
                    'Đơn vị: triệu đồng',
                    style: textTheme.navTitleTextStyle,
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(bottom: space6),
                  child: NonoHorizontalMultiBarChart(
                    height: MediaQuery.of(context).size.height * 3,
                    axisColor: CupertinoColors.black,
                    firstBarConfigsList: state.buyingPricesMap.entries
                        .map(
                          (e) =>
                              SingleBarConfigs(xLabel: e.key, yValue: e.value),
                        )
                        .toList(),
                    secondBarConfigsList: state.sellingPricesMap.entries
                        .map(
                          (e) =>
                              SingleBarConfigs(xLabel: e.key, yValue: e.value),
                        )
                        .toList(),
                    firstBarColor: brandNormalColor,
                    secondBarColor: brandPositiveColor,
                    firstBarLabel: 'Giá mua',
                    secondBarLabel: 'Giá bán',
                    yValueFormat: NumberFormat("#,##0.00", "en_US"),
                    valueFormat: NumberFormat("#,##0.00", "en_US"),
                  ),
                );
              }
            },
          ),
        )
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody();

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () {
            return context
                .read<GoldPricesPageCubit>()
                .refresh()
                .then((value) => Future.delayed(const Duration(seconds: 2)));
          },
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: 3,
            (context, itemIndex) {
              return Container(
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: space4),
                child: ErrorBody(
                  errorMessage: 'Không tìm thấy thông tin giá vàng',
                  errorTextStyle: textTheme.navTitleTextStyle,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
