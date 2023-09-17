import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nono_finance/domain/entity/currency.dart';
import 'package:nono_finance/shared/colors.dart';
import 'package:nono_finance/shared/extension/data_ext.dart';

import '../shared/formatter/date_time_formatter.dart';
import '../shared/widget/info_banner.dart';
import 'exchange_type.dart';
import '../shared/dimens.dart';
import '../shared/widget/bar_chart_list_skeleton.dart';
import '../shared/widget/chart/bar_chart/nono_horizontal_bar_chart.dart';
import '../shared/widget/chart/bar_chart/not_applicable_text.dart';
import '../shared/widget/cupertino_widget_util.dart';
import '../shared/widget/error_body.dart';
import '../shared/widget/nono_icon.dart';
import 'exchange_page_cubit.dart';
import 'exchange_page_state.dart';

class ExchangePageIOS extends StatelessWidget {
  const ExchangePageIOS({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = ModalRoute.of(context)?.settings.arguments as Currency;
    return BlocProvider(
      create: (context) => ExchangePageCubit(currency)..init(),
      child: BlocBuilder<ExchangePageCubit, ExchangePageState>(
        builder: (context, state) {
          return _ExchangePage(currency, state);
        },
      ),
    );
  }
}

class _ExchangePage extends StatelessWidget {
  const _ExchangePage(this.currency, this.pageState);

  final Currency currency;
  final ExchangePageState pageState;

  @override
  Widget build(BuildContext context) {
    final state = pageState;
    String pageTitle =
        '${currency.defaultName} (${currency.code.toUpperCase()})';
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(pageTitle),
        trailing: switch (state) {
          ExchangePageInitialState() ||
          ExchangePageFailureState() =>
            const SizedBox.shrink(),
          ExchangePageInitializedState() => CupertinoButton(
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
                  selectedAction: state.type,
                  title: 'Chọn danh mục',
                  message: 'Lựa chọn cách hiển thị thông tin tỉ giá',
                  cancelButtonLabel: 'Huỷ',
                  actionMap: {
                    for (final type in ExchangeType.values) type: type.label
                  },
                  onActionSelected: (ExchangeType type) {
                    context.read<ExchangePageCubit>().changeType(type);
                  },
                );
              },
            ),
        },
      ),
      child: SafeArea(
        child: switch (state) {
          ExchangePageInitialState() => const BarChartListSkeleton(
              startColor: CupertinoColors.systemGrey,
              endColor: CupertinoColors.systemGrey4,
            ),
          ExchangePageInitializedState() => _InitializedBody(state),
          ExchangePageFailureState() => _ErrorBody(currency),
        },
      ),
    );
  }
}

const _horizontalBarHeight = 50.0;
const _verticalBarChartHeight = 300.0;

class _InitializedBody extends StatelessWidget {
  const _InitializedBody(this.state);

  final ExchangePageInitializedState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () {
            return context
                .read<ExchangePageCubit>()
                .changeType(state.type)
                .then((value) => Future.delayed(const Duration(seconds: 2)));
          },
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: state.exchangesByGroup.keys.length + 1,
            (context, itemIndex) {
              if (itemIndex == 0) {
                final updatedAtString = formatUpdatedTime(state.updatedAt);
                return Container(
                  padding: const EdgeInsets.only(
                    top: space1,
                    left: spaceHalf,
                    bottom: space1,
                  ),
                  child: InfoBanner(
                    message: 'Cập nhật lúc: $updatedAtString',
                    textStyle: textTheme.textStyle,
                  ),
                );
              }
              final index = itemIndex - 1;
              final group = state.exchangesByGroup.keys.elementAt(index);
              final barData = state.exchangesByGroup[group]!;
              final height = state.type == ExchangeType.bank
                  ? _verticalBarChartHeight
                  : barData.length * _horizontalBarHeight;
              return Padding(
                padding: const EdgeInsets.only(right: spaceHalf),
                child: NonoHorizontalBarChart(
                  groupName: group,
                  barData: barData,
                  barColor: brandNormalColor,
                  maxColor: brandPositiveColor,
                  minColor: brandNegativeColor,
                  axisColor: CupertinoColors.black,
                  height: height,
                  valueFormat: NumberFormat("#,##0.00", "en_US"),
                  yValueFormat: NumberFormat("#,###", "en_US"),
                  groupNameStyle: textTheme.navTitleTextStyle,
                  barValueTextStyle: textTheme.tabLabelTextStyle,
                  notes: _generateNoteWidgets(textTheme, barData),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Iterable<Widget> _generateNoteWidgets(
    CupertinoTextThemeData textTheme,
    Map<String, double> barData,
  ) {
    final hasNABar = barData.values
        .where((element) => element == double.negativeInfinity)
        .isNotEmpty;

    return [
      Text('* Đơn vị: đồng', style: textTheme.tabLabelTextStyle),
      const SizedBox(height: spaceQuarter),
      if (hasNABar)
        NotApplicableText(
          textStyle: textTheme.tabLabelTextStyle,
        ),
      const SizedBox(height: space2),
    ];
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody(this.currency);

  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () {
            return context
                .read<ExchangePageCubit>()
                .refresh()
                .then((value) => Future.delayed(const Duration(seconds: 2)));
          },
        ),
        SliverFillRemaining(
          child: ErrorBody(
            errorMessage:
                'Không tìm thấy thông tin tỉ giá của\n${currency.defaultName} - ${currency.code.toUpperCase()}',
            errorTextStyle: textTheme.navTitleTextStyle,
          ),
        )
      ],
    );
  }
}
