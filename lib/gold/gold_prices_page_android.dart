import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nono_finance/gold/gold_price_type.dart';
import 'package:nono_finance/shared/colors.dart';
import 'package:nono_finance/shared/extension/data_ext.dart';
import 'package:nono_finance/shared/widget/chart/bar_chart/nono_horizontal_multi_bar_chart.dart';
import 'package:nono_finance/shared/widget/chart/bar_chart/double_bar_configs.dart';

import '../shared/dimens.dart';
import '../shared/widget/bar_chart_list_skeleton.dart';
import '../shared/widget/chart/bar_chart/nono_horizontal_bar_chart.dart';
import '../shared/widget/error_body.dart';
import '../shared/widget/material_widget_util.dart';
import '../shared/widget/nono_icon.dart';
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
              title: Text(_getTitle(state)),
              actions: [
                BlocBuilder<GoldPricesPageCubit, GoldPricesState>(
                  builder: (context, state) {
                    return switch (state) {
                      GoldPricesInitialState() ||
                      GoldPricesFailureState() =>
                        const SizedBox.shrink(),
                      GoldPricesFullState() => _ChangeTypeButton(state.type),
                      GoldPricesPartialState() => _ChangeTypeButton(state.type),
                    };
                  },
                )
              ],
            ),
            body: switch (state) {
              GoldPricesInitialState() => BarChartListSkeleton(
                  startColor: Colors.grey[800]!,
                  endColor: Colors.grey[400]!,
                ),
              GoldPricesFullState() => _FullDataBody(state),
              GoldPricesPartialState() => _PartialDataBody(state),
              GoldPricesFailureState() => _ErrorBody(state),
            },
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

class _FullDataBody extends StatelessWidget {
  const _FullDataBody(this.state);

  final GoldPricesFullState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      edgeOffset: 0.0,
      onRefresh: () async {
        return context
            .read<GoldPricesPageCubit>()
            .refresh(state.type)
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

const _horizontalBarBaseHeight = 60.0;

class _PartialDataBody extends StatelessWidget {
  const _PartialDataBody(this.state);

  final GoldPricesPartialState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      edgeOffset: 0.0,
      onRefresh: () async {
        return context
            .read<GoldPricesPageCubit>()
            .refresh(state.type)
            .then((value) => Future.delayed(const Duration(seconds: 2)));
      },
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: space1),
            child: Text('Đơn vị: triệu đồng', style: textTheme.titleMedium),
          ),
          NonoHorizontalBarChart(
            groupName: '',
            barData: state.pricesMap,
            barColor: brandNormalColor,
            maxColor: brandPositiveColor,
            minColor: brandNegativeColor,
            axisColor: Colors.black,
            height: state.pricesMap.length * _horizontalBarBaseHeight,
            groupNameStyle: textTheme.bodyLarge,
            barValueTextStyle: textTheme.bodySmall!,
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody(this.state);

  final GoldPricesFailureState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      edgeOffset: 0.0,
      onRefresh: () async {
        return context
            .read<GoldPricesPageCubit>()
            .refresh(state.type)
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

class _ChangeTypeButton extends StatelessWidget {
  const _ChangeTypeButton(this.type);

  final GoldPriceType type;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      icon: const NonoIcon(
        'assets/icon/ic_swap.svg',
        width: actionBarIconSize,
        height: actionBarIconSize,
      ),
      onPressed: () {
        showActionsModalPopup(
          context: context,
          selectedAction: type,
          title: 'Chọn danh mục',
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
