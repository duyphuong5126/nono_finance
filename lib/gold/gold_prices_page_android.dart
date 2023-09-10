import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nono_finance/domain/entity/gold_prices.dart';
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
import 'gold_price_data_formatter.dart';
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

const leftMargin = EdgeInsets.only(
  left: spaceHalf,
  right: spaceQuarter,
  bottom: spaceHalf,
);
const rightMargin = EdgeInsets.only(
  left: spaceQuarter,
  right: spaceHalf,
  bottom: spaceHalf,
);
const highlightPadding = EdgeInsets.symmetric(
  vertical: spaceHalf,
  horizontal: spaceQuarter,
);

class _FullDataBody extends StatelessWidget {
  _FullDataBody(this.state);

  final GoldPricesFullState state;

  final GoldPricesFormatter _pricesFormatter = GoldPricesFormatter();

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
            padding: const EdgeInsets.only(left: space1, bottom: space1),
            child: Text('Nổi bật', style: textTheme.titleMedium),
          ),
          _HighLightRow(
            firstData: _pricesFormatter
                .formatHighestBuyingPrice(state.highestBuyingPrice),
            secondData: _pricesFormatter
                .formatHighestSellingPrice(state.highestSellingPrice),
            firstColor: brandPositiveColor,
            secondColor: brandPositiveColor,
          ),
          _HighLightRow(
            firstData: _pricesFormatter
                .formatLowestBuyingPrice(state.lowestBuyingPrice),
            secondData: _pricesFormatter
                .formatLowestSellingPrice(state.lowestSellingPrice),
            firstColor: brandNegativeColor,
            secondColor: brandNegativeColor,
          ),
          _GlobalGoldPrice(state.globalPrice),
          Padding(
            padding: const EdgeInsets.only(left: space1, top: space1),
            child: Text(
              'Giá vàng chi tiết (Đơn vị: triệu đồng)',
              style: textTheme.titleMedium,
            ),
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
  _PartialDataBody(this.state);

  final GoldPricesPartialState state;

  final GoldPricesFormatter _pricesFormatter = GoldPricesFormatter();

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
            padding: const EdgeInsets.only(left: space1, bottom: space1),
            child: Text('Nổi bật', style: textTheme.titleMedium),
          ),
          _HighLightRow(
            firstData: _pricesFormatter.formatHighestPrice(state.highestPrice),
            secondData: _pricesFormatter.formatLowestPrice(state.lowestPrice),
            firstColor: brandPositiveColor,
            secondColor: brandNegativeColor,
          ),
          _GlobalGoldPrice(state.globalPrice),
          Padding(
            padding: const EdgeInsets.only(left: space1),
            child: Text(
              'Giá vàng chi tiết (Đơn vị: triệu đồng)',
              style: textTheme.titleMedium,
            ),
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

class _HighLightRow extends StatelessWidget {
  const _HighLightRow({
    required this.firstData,
    required this.secondData,
    required this.firstColor,
    required this.secondColor,
  });

  final String firstData;
  final String secondData;
  final Color firstColor;
  final Color secondColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: firstColor),
              borderRadius: const BorderRadius.all(Radius.circular(spaceHalf)),
            ),
            margin: leftMargin,
            padding: highlightPadding,
            child: Text(
              firstData,
              style: textTheme.bodyLarge?.copyWith(color: firstColor),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: secondColor),
              borderRadius: const BorderRadius.all(Radius.circular(spaceHalf)),
            ),
            margin: rightMargin,
            padding: highlightPadding,
            child: Text(
              secondData,
              style: textTheme.bodyLarge?.copyWith(color: secondColor),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlobalGoldPrice extends StatelessWidget {
  _GlobalGoldPrice(this._globalPriceHistory);

  final GoldPricesFormatter _pricesFormatter = GoldPricesFormatter();

  final GoldPriceHistory _globalPriceHistory;

  @override
  Widget build(BuildContext context) {
    final priceChangeInDollar = _globalPriceHistory.priceChangeInDollar;
    final priceChangeInPercent = _globalPriceHistory.priceChangeInPercent;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: brandNormalColor),
            borderRadius: const BorderRadius.all(Radius.circular(spaceHalf)),
          ),
          margin: const EdgeInsets.only(
            left: spaceHalf,
            right: spaceHalf,
            bottom: spaceHalf,
          ),
          padding: const EdgeInsets.all(space1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Giá vàng thế giới: ${_pricesFormatter.formatGlobalPrice(
                  _globalPriceHistory.priceInDollar,
                )}',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(
                height: spaceHalf,
              ),
              Row(
                children: [
                  Text(
                    '${_pricesFormatter.formatGlobalPriceChangeLabel(priceChangeInDollar)} ',
                    style: textTheme.bodyLarge,
                  ),
                  Text(
                    _pricesFormatter.formatGlobalPriceChange(
                      priceChangeInDollar,
                    ),
                    style: textTheme.bodyLarge?.copyWith(
                      color: priceChangeInDollar > 0
                          ? brandPositiveColor
                          : priceChangeInDollar < 0
                              ? brandNegativeColor
                              : Colors.grey[900],
                    ),
                  ),
                  Text(
                    '(${_pricesFormatter.formatGlobalPriceChangeInPercent(
                      priceChangeInPercent,
                    )})',
                    style: textTheme.bodyLarge?.copyWith(
                      color: priceChangeInPercent > 0
                          ? brandPositiveColor
                          : priceChangeInPercent < 0
                              ? brandNegativeColor
                              : Colors.grey[900],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
