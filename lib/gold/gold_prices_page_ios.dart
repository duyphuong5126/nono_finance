import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nono_finance/shared/extension/data_ext.dart';
import 'package:nono_finance/shared/widget/cupertino_widget_util.dart';

import '../domain/entity/gold_prices.dart';
import '../shared/colors.dart';
import '../shared/dimens.dart';
import '../shared/formatter/date_time_formatter.dart';
import '../shared/widget/chart/bar_chart/double_bar_configs.dart';
import '../shared/widget/chart/bar_chart/nono_horizontal_bar_chart.dart';
import '../shared/widget/chart/bar_chart/nono_horizontal_multi_bar_chart.dart';
import '../shared/widget/error_body.dart';
import '../shared/widget/highlight_row.dart';
import '../shared/widget/info_banner.dart';
import '../shared/widget/loading_body.dart';
import '../shared/widget/nono_icon.dart';
import 'gold_price_data_formatter.dart';
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
                GoldPricesFullState() => _ChangeTypeButton(state.type),
                GoldPricesPartialState() => _ChangeTypeButton(state.type),
                _ => const SizedBox.shrink(),
              },
            ),
            child: SafeArea(
              child: switch (state) {
                GoldPricesInitialState() => const LoadingBody(),
                GoldPricesFullState() => _FullDataBody(state),
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
    final textTheme = CupertinoTheme.of(context).textTheme;
    final updatedAtString = formatUpdatedTime(state.updatedAt);
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
                    Padding(
                      padding: const EdgeInsets.only(
                        left: space1,
                        bottom: space1,
                      ),
                      child: Text(
                        'Nổi bật',
                        style: textTheme.navTitleTextStyle,
                      ),
                    ),
                    HighLightRow(
                      firstData: _pricesFormatter
                          .formatHighestBuyingPrice(state.highestBuyingPrice),
                      secondData: _pricesFormatter
                          .formatHighestSellingPrice(state.highestSellingPrice),
                      firstColor: brandPositiveColor,
                      secondColor: brandPositiveColor,
                      textStyle: textTheme.textStyle,
                    ),
                    HighLightRow(
                      firstData: _pricesFormatter
                          .formatLowestBuyingPrice(state.lowestBuyingPrice),
                      secondData: _pricesFormatter
                          .formatLowestSellingPrice(state.lowestSellingPrice),
                      firstColor: brandNegativeColor,
                      secondColor: brandNegativeColor,
                      textStyle: textTheme.textStyle,
                    ),
                    _GlobalGoldPrice(state.globalPrice),
                    Padding(
                      padding: const EdgeInsets.only(left: space1, top: space1),
                      child: Text(
                        'Giá vàng chi tiết (Đơn vị: triệu đồng)',
                        style: textTheme.navTitleTextStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: space1,
                        top: spaceQuarter,
                        bottom: spaceQuarter,
                      ),
                      child: Text(
                        '* Giá bán ra',
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
                        '* Giá mua vào',
                        style: textTheme.navTitleTextStyle
                            .copyWith(color: brandNegativeColor),
                      ),
                    ),
                  ],
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
                    firstBarColor: brandNegativeColor,
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
            childCount: 1,
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
  _PartialDataBody(this.state);

  final GoldPricesPartialState state;

  final GoldPricesFormatter _pricesFormatter = GoldPricesFormatter();

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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: space1,
                        bottom: space1,
                        top: space1,
                      ),
                      child: Text(
                        'Nổi bật',
                        style: textTheme.navTitleTextStyle,
                      ),
                    ),
                    HighLightRow(
                      firstData: _pricesFormatter
                          .formatHighestPrice(state.highestPrice),
                      secondData:
                          _pricesFormatter.formatLowestPrice(state.lowestPrice),
                      firstColor: brandPositiveColor,
                      secondColor: brandNegativeColor,
                      textStyle: textTheme.textStyle,
                    ),
                    _GlobalGoldPrice(state.globalPrice),
                    Padding(
                      padding: const EdgeInsets.only(left: space1, top: space1),
                      child: Text(
                        'Giá vàng chi tiết (Đơn vị: triệu đồng)',
                        style: textTheme.navTitleTextStyle,
                      ),
                    ),
                  ],
                );
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

class _GlobalGoldPrice extends StatelessWidget {
  _GlobalGoldPrice(this._globalPriceHistory);

  final GoldPricesFormatter _pricesFormatter = GoldPricesFormatter();

  final GoldPriceHistory _globalPriceHistory;

  @override
  Widget build(BuildContext context) {
    final priceChangeInDollar = _globalPriceHistory.priceChangeInDollar;
    final priceChangeInPercent = _globalPriceHistory.priceChangeInPercent;
    final textTheme = CupertinoTheme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.darkBackgroundGray),
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
                style: textTheme.textStyle,
              ),
              const SizedBox(
                height: spaceHalf,
              ),
              Row(
                children: [
                  Text(
                    '${_pricesFormatter.formatGlobalPriceChangeLabel(priceChangeInDollar)} ',
                    style: textTheme.textStyle,
                  ),
                  Text(
                    _pricesFormatter.formatGlobalPriceChange(
                      priceChangeInDollar,
                    ),
                    style: textTheme.textStyle.copyWith(
                      color: priceChangeInDollar > 0
                          ? brandPositiveColor
                          : priceChangeInDollar < 0
                              ? brandNegativeColor
                              : CupertinoColors.systemGrey,
                    ),
                  ),
                  Text(
                    '(${_pricesFormatter.formatGlobalPriceChangeInPercent(
                      priceChangeInPercent,
                    )})',
                    style: textTheme.textStyle.copyWith(
                      color: priceChangeInPercent > 0
                          ? brandPositiveColor
                          : priceChangeInPercent < 0
                              ? brandNegativeColor
                              : CupertinoColors.systemGrey,
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
