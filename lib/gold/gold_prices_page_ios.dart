import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nono_finance/shared/extension/data_ext.dart';
import 'package:nono_finance/shared/widget/cupertino_widget_util.dart';

import '../shared/colors.dart';
import '../shared/dimens.dart';
import '../shared/widget/bar_chart_list_skeleton.dart';
import '../shared/widget/chart/bar_chart/double_bar_configs.dart';
import '../shared/widget/chart/bar_chart/nono_horizontal_bar_chart.dart';
import '../shared/widget/chart/bar_chart/nono_horizontal_multi_bar_chart.dart';
import '../shared/widget/error_body.dart';
import '../shared/widget/nono_icon.dart';
import 'gold_price_type.dart';
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
            navigationBar: CupertinoNavigationBar(
              middle: Text(_getTitle(state)),
              trailing: switch (state) {
                GoldPricesInitialState() ||
                GoldPricesFailureState() =>
                  const SizedBox.shrink(),
                GoldPricesFullState() => _ChangeTypeButton(state.type),
                GoldPricesPartialState() => _ChangeTypeButton(state.type),
              },
            ),
            child: SafeArea(
              child: switch (state) {
                GoldPricesInitialState() => const BarChartListSkeleton(
                    startColor: CupertinoColors.systemGrey,
                    endColor: CupertinoColors.systemGrey4,
                  ),
                GoldPricesFullState() => _InitializedBody(state),
                GoldPricesPartialState() => _PartialDataBody(state),
                GoldPricesFailureState() => _ErrorBody(state),
              },
            ),
          );
        },
      ),
    );
  }

  String _getTitle(GoldPricesState state) {
    return switch (state) {
      GoldPricesInitialState() => 'Đang tải',
      GoldPricesFailureState() => 'Có lỗi xảy ra',
      GoldPricesFullState() => state.type.title,
      GoldPricesPartialState() => state.type.title,
    };
  }
}

class _InitializedBody extends StatelessWidget {
  const _InitializedBody(this.state);

  final GoldPricesFullState state;

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
                .refresh(state.type)
                .then((value) => Future.delayed(const Duration(seconds: 2)));
          },
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: 2,
            (context, itemIndex) {
              if (itemIndex == 0) {
                return Padding(
                  padding: const EdgeInsets.only(left: space1, top: space1),
                  child: Text(
                    'Đơn vị: triệu đồng',
                    style: textTheme.navTitleTextStyle,
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(bottom: space2),
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
  const _ErrorBody(this.state);

  final GoldPricesFailureState state;

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
                .refresh(state.type)
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

const _horizontalBarBaseHeight = 60.0;

class _PartialDataBody extends StatelessWidget {
  const _PartialDataBody(this.state);

  final GoldPricesPartialState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    return CustomScrollView(
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () {
            return context
                .read<GoldPricesPageCubit>()
                .refresh(state.type)
                .then((value) => Future.delayed(const Duration(seconds: 2)));
          },
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: 2,
            (context, itemIndex) {
              if (itemIndex == 0) {
                return const SizedBox(height: space1);
              }
              return NonoHorizontalBarChart(
                groupName: '',
                barData: state.pricesMap,
                barColor: brandNormalColor,
                maxColor: brandPositiveColor,
                minColor: brandNegativeColor,
                axisColor: CupertinoColors.black,
                height: state.pricesMap.length * _horizontalBarBaseHeight,
                groupNameStyle: textTheme.navTitleTextStyle,
                barValueTextStyle: textTheme.tabLabelTextStyle,
              );
            },
          ),
        )
      ],
    );
  }
}

class _ChangeTypeButton extends StatelessWidget {
  const _ChangeTypeButton(this.type);

  final GoldPriceType type;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: const NonoIcon(
        'assets/icon/ic_swap.svg',
        width: actionBarIconSize,
        height: actionBarIconSize,
        color: CupertinoColors.systemBlue,
      ),
      onPressed: () {
        showActionsModalPopup(
          context: context,
          selectedAction: type,
          title: 'Chọn danh mục',
          message: 'Lựa chọn cách hiển thị thông tin giá vàng',
          cancelButtonLabel: 'Huỷ',
          actionMap: {
            for (final type in GoldPriceType.values) type: type.label
          },
          onActionSelected: (GoldPriceType type) {
            context.read<GoldPricesPageCubit>().changeType(type);
          },
        );
      },
    );
  }
}
