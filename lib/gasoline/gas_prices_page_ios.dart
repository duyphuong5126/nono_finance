import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../shared/colors.dart';
import '../shared/dimens.dart';
import '../shared/formatter/date_time_formatter.dart';
import '../shared/widget/bar_chart_list_skeleton.dart';
import '../shared/widget/chart/bar_chart/double_bar_configs.dart';
import '../shared/widget/chart/bar_chart/nono_horizontal_multi_bar_chart.dart';
import '../shared/widget/error_body.dart';
import '../shared/widget/info_banner.dart';
import 'gas_prices_cubit.dart';
import 'gas_prices_state.dart';

class GasPricesPageIOS extends StatelessWidget {
  const GasPricesPageIOS({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GasPricesCubit()..init(),
      child: BlocBuilder<GasPricesCubit, GasPricesState>(
        builder: (context, state) {
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: switch (state) {
                GoldPricesInitialState() => const Text('Đang tải', maxLines: 2),
                _ => const Text('Giá xăng', maxLines: 2),
              },
            ),
            child: SafeArea(
              child: switch (state) {
                GoldPricesInitialState() => const BarChartListSkeleton(
                    startColor: CupertinoColors.systemGrey,
                    endColor: CupertinoColors.systemGrey4,
                  ),
                GoldPricesInitializedState() => _InitializedBody(state),
                GoldPricesFailureState() => const _ErrorBody(),
              },
            ),
          );
        },
      ),
    );
  }
}

const _horizontalBarBaseHeight = 100.0;

class _InitializedBody extends StatelessWidget {
  const _InitializedBody(this._state);

  final GoldPricesInitializedState _state;

  @override
  Widget build(BuildContext context) {
    if (_state.prices.isEmpty) {
      return const _ErrorBody();
    }
    final textTheme = CupertinoTheme.of(context).textTheme;
    final updatedAtString = formatUpdatedTime(_state.updatedAt);
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () {
            return context
                .read<GasPricesCubit>()
                .refresh()
                .then((value) => Future.delayed(const Duration(seconds: 2)));
          },
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: 1,
            (context, itemIndex) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      left: spaceHalf,
                      right: spaceHalf,
                      top: spaceHalf,
                      bottom: space1,
                    ),
                    child: InfoBanner(
                      message: 'Cập nhật lúc: $updatedAtString',
                      textStyle: textTheme.textStyle,
                      backgroundColor: CupertinoColors.systemGrey5,
                    ),
                  ),
                  NonoHorizontalMultiBarChart(
                    height: _state.prices.length * _horizontalBarBaseHeight,
                    axisColor: CupertinoColors.black,
                    firstBarConfigsList: _state.prices
                        .map(
                          (e) => SingleBarConfigs(
                            xLabel: e.sellerName,
                            yValue: e.area1Price,
                          ),
                        )
                        .toList(),
                    secondBarConfigsList: _state.prices
                        .map(
                          (e) => SingleBarConfigs(
                            xLabel: e.sellerName,
                            yValue: e.area2Price,
                          ),
                        )
                        .toList(),
                    firstBarColor: brandPositiveColor,
                    secondBarColor: brandNormalColor,
                    firstBarLabel: 'Giá vùng 1',
                    secondBarLabel: 'Giá vùng 2',
                    yValueFormat: NumberFormat("#,##0.00", "en_US"),
                    valueFormat: NumberFormat("#,##0.00", "en_US"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: space1,
                      bottom: spaceQuarter,
                    ),
                    child: Text(
                      'Đơn vị: nghìn đồng',
                      style: textTheme.navTitleTextStyle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: space1,
                      bottom: spaceQuarter,
                    ),
                    child: Text(
                      '* Giá vùng 1',
                      style: textTheme.navTitleTextStyle
                          .copyWith(color: brandPositiveColor),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: space1,
                      bottom: spaceQuarter,
                    ),
                    child: Text(
                      '* Giá vùng 2',
                      style: textTheme.navTitleTextStyle
                          .copyWith(color: brandNormalColor),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
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
                .read<GasPricesCubit>()
                .refresh()
                .then((value) => Future.delayed(const Duration(seconds: 2)));
          },
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: 1,
            (context, itemIndex) {
              return Container(
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: space4),
                child: ErrorBody(
                  errorMessage: 'Không tìm thấy thông tin giá xăng',
                  errorTextStyle: textTheme.navTitleTextStyle,
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
