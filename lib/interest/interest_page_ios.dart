import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:nono_finance/shared/colors.dart';
import 'package:nono_finance/shared/extension/data_ext.dart';
import 'package:nono_finance/shared/widget/cupertino_widget_util.dart';
import 'package:nono_finance/shared/widget/view_mode/view_mode.dart';
import 'package:nono_finance/shared/widget/view_mode/view_mode_switcher.dart';

import '../shared/dimens.dart';
import '../shared/formatter/date_time_formatter.dart';
import '../shared/widget/chart/bar_chart/nono_horizontal_bar_chart.dart';
import '../shared/widget/chart/bar_chart/not_applicable_text.dart';
import '../shared/widget/info_banner.dart';
import '../shared/widget/loading_body.dart';
import '../shared/widget/nono_icon.dart';
import '../shared/widget/chart/bar_chart/nono_bar_chart.dart';
import 'interest_cubit.dart';
import 'interest_data_descriptions.dart';
import 'interest_state.dart';
import 'interest_type.dart';

class InterestPageIOS extends StatelessWidget {
  const InterestPageIOS({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InterestCubit()..init(),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: BlocBuilder<InterestCubit, InterestState>(
            builder: (context, state) {
              final text = switch (state) {
                InterestInitialState() => 'Đang tải...',
                InterestInitializedState() => state.type.title,
              };
              return Text(text);
            },
          ),
          trailing: BlocBuilder<InterestCubit, InterestState>(
            builder: (context, state) {
              return switch (state) {
                InterestInitialState() => const SizedBox.shrink(),
                InterestInitializedState() => CupertinoButton(
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
                        message: 'Lựa chọn danh mục lãi suất bạn đang quan tâm',
                        cancelButtonLabel: 'Huỷ',
                        actionMap: {
                          for (final type in InterestType.values)
                            type: type.label,
                        },
                        onActionSelected: (InterestType type) {
                          context
                              .read<InterestCubit>()
                              .changeInterestType(type);
                        },
                      );
                    },
                  ),
              };
            },
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<InterestCubit, InterestState>(
            builder: (context, state) {
              return switch (state) {
                InterestInitialState() => const LoadingBody(),
                InterestInitializedState() => _InitializedBody(state)
              };
            },
          ),
        ),
      ),
    );
  }
}

const _barChartBaseHeight = 350.0;
const _horizontalBarBaseHeight = 30.0;
const _noteItemHeight = 10.0;

class _InitializedBody extends StatelessWidget {
  const _InitializedBody(this.state);

  final InterestInitializedState state;

  @override
  Widget build(BuildContext context) {
    return switch (state.viewMode) {
      ViewMode.chart => _ChartBody(state),
      ViewMode.plainText => _PlainTextBody(state),
    };
  }
}

class _PlainTextBody extends StatelessWidget {
  const _PlainTextBody(this.state);

  final InterestInitializedState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    return CustomScrollView(
      slivers: [
        _Refresher(state),
        _Header(state),
        _generateFullNoteWidget(textTheme),
        for (final group in state.interestRatesByGroup.keys) ...[
          _plainTextItem(textTheme, group),
          const SliverToBoxAdapter(child: SizedBox(height: space1)),
        ],
      ],
    );
  }

  Widget _plainTextItem(CupertinoTextThemeData textTheme, String group) {
    final terms = state.interestRatesByGroup[group]!.keys;
    final barData = state.interestRatesByGroup[group]!;
    final values = barData.values.whereNotNull().where((value) => value >= 0);
    double min = values.isNotEmpty ? values.min : -123;
    double max = values.isNotEmpty ? values.max : -123;
    return SliverStickyHeader(
      header: Container(
        color: brandNormalColor,
        padding: const EdgeInsets.symmetric(
          vertical: spaceHalf,
          horizontal: space1,
        ),
        child: Text(group, style: textTheme.navTitleTextStyle),
      ),
      sliver: SliverList.builder(
        itemCount: terms.length,
        itemBuilder: (context, index) {
          final term = terms.elementAt(index);
          final interest = barData[term] ?? -1;
          final isValidInterest = interest.isFinite && interest > 0;
          final valueColor = interest == max
              ? brandPositiveColor
              : interest == min && isValidInterest
                  ? brandNegativeColor
                  : null;
          final valueTextStyle = valueColor != null
              ? textTheme.textStyle.copyWith(color: valueColor)
              : textTheme.textStyle;
          return Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: spaceQuarter),
                  alignment: Alignment.center,
                  child: Text(term, style: textTheme.navTitleTextStyle),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    isValidInterest ? interest.toString() : "-",
                    style: valueTextStyle,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _generateFullNoteWidget(CupertinoTextThemeData textTheme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: spaceHalf, bottom: space1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('* Đơn vị lãi suất: %/năm', style: textTheme.actionTextStyle),
            const SizedBox(height: spaceQuarter),
            Text('* KKH: Không kỳ hạn', style: textTheme.actionTextStyle),
            const SizedBox(height: spaceQuarter),
            NotApplicableText(
              textStyle: textTheme.actionTextStyle.copyWith(
                color: brandNegativeColor,
              ),
              notApplicableColor: brandNegativeColor,
            ),
            const SizedBox(height: spaceQuarter),
            Text(
              '* Lãi suất cao nhất',
              style: textTheme.actionTextStyle.copyWith(
                color: brandPositiveColor,
              ),
            ),
            const SizedBox(height: spaceQuarter),
            Text(
              '* Lãi suất thấp nhất',
              style: textTheme.actionTextStyle.copyWith(
                color: brandNegativeColor,
              ),
            ),
            const SizedBox(height: spaceQuarter),
          ],
        ),
      ),
    );
  }
}

class _ChartBody extends StatelessWidget {
  const _ChartBody(this.state);

  final InterestInitializedState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    return CustomScrollView(
      slivers: [
        _Refresher(state),
        _Header(state),
        for (final group in state.interestRatesByGroup.keys)
          _chartItem(textTheme, group),
      ],
    );
  }

  Widget _chartItem(CupertinoTextThemeData textTheme, String group) {
    final barData = state.interestRatesByGroup[group]!;
    final description = state.descriptionsByGroup[group]!;
    final notes = switch (state.type) {
      InterestType.onlineByBank ||
      InterestType.counterByBank =>
        _generateChartNoteWidgets(
          textTheme,
          barData,
          description,
        ),
      InterestType.onlineByTerm ||
      InterestType.counterByTerm =>
        _generateHorizontalChartNoteWidgets(
          textTheme,
          barData,
          description,
        ),
    };
    final totalNoteHeight = notes.length * _noteItemHeight;
    final widget = switch (state.type) {
      InterestType.onlineByBank || InterestType.counterByBank => barData
              .isNotEmpty
          ? NonoBarChart(
              groupName: group,
              barData: barData,
              barColor: brandNormalColor,
              maxColor: brandPositiveColor,
              minColor: brandNegativeColor,
              notApplicableColor: brandNegativeColor,
              axisGroupPadding: 48,
              groupNameBottomPadding: space1,
              height: _barChartBaseHeight + totalNoteHeight,
              groupNameStyle: textTheme.navTitleTextStyle,
              barValueTextStyle: textTheme.tabLabelTextStyle,
              valueSegmentTitleTextStyle: textTheme.tabLabelTextStyle.copyWith(
                color: CupertinoColors.black,
              ),
              notes: notes,
            )
          : const SizedBox.shrink(),
      InterestType.onlineByTerm ||
      InterestType.counterByTerm =>
        barData.isNotEmpty
            ? NonoHorizontalBarChart(
                groupName: group,
                barData: barData,
                barColor: brandNormalColor,
                maxColor: brandPositiveColor,
                minColor: brandNegativeColor,
                axisColor: CupertinoColors.black,
                height:
                    barData.length * _horizontalBarBaseHeight + totalNoteHeight,
                groupNameStyle: textTheme.navTitleTextStyle,
                barValueTextStyle: textTheme.tabLabelTextStyle,
                notes: notes,
              )
            : const SizedBox.shrink()
    };
    return SliverToBoxAdapter(child: widget);
  }

  Iterable<Widget> _generateChartNoteWidgets(
    CupertinoTextThemeData textTheme,
    Map<String, double> barData,
    InterestDataDescriptions descriptions,
  ) {
    final hasNABar = barData.values.where((element) => element < 0).isNotEmpty;

    return [
      const SizedBox(height: 48),
      Text('* Đơn vị lãi suất: %/năm', style: textTheme.actionTextStyle),
      const SizedBox(height: spaceQuarter),
      Text('* KKH: Không kỳ hạn', style: textTheme.actionTextStyle),
      const SizedBox(height: spaceQuarter),
      if (hasNABar) ...[
        NotApplicableText(
          textStyle: textTheme.actionTextStyle.copyWith(
            color: brandNegativeColor,
          ),
          notApplicableColor: brandNegativeColor,
        ),
        const SizedBox(height: spaceQuarter),
      ],
      if (descriptions.hasMinMax) ...[
        Text(
          '* Lãi suất cao nhất',
          style: textTheme.actionTextStyle.copyWith(
            color: brandPositiveColor,
          ),
        ),
        const SizedBox(height: spaceQuarter),
        Text(
          '* Lãi suất thấp nhất',
          style: textTheme.actionTextStyle.copyWith(
            color: brandNegativeColor,
          ),
        ),
        const SizedBox(height: spaceQuarter),
      ],
    ];
  }

  Iterable<Widget> _generateHorizontalChartNoteWidgets(
    CupertinoTextThemeData textTheme,
    Map<String, double> barData,
    InterestDataDescriptions descriptions,
  ) {
    final hasNABar = barData.values
        .where((element) => element == double.negativeInfinity)
        .isNotEmpty;

    return [
      Text('* Đơn vị lãi suất: %/năm', style: textTheme.actionTextStyle),
      const SizedBox(height: spaceQuarter),
      Text('* KKH: Không kỳ hạn', style: textTheme.actionTextStyle),
      const SizedBox(height: spaceQuarter),
      if (hasNABar) ...[
        NotApplicableText(
          textStyle: textTheme.actionTextStyle.copyWith(
            color: CupertinoColors.black,
          ),
          notApplicableColor: CupertinoColors.black,
        ),
        const SizedBox(height: spaceQuarter),
      ],
      if (descriptions.hasMinMax) ...[
        Text(
          '* Lãi suất cao nhất',
          style: textTheme.actionTextStyle.copyWith(
            color: brandPositiveColor,
          ),
        ),
        const SizedBox(height: spaceQuarter),
        Text(
          '* Lãi suất thấp nhất',
          style: textTheme.actionTextStyle.copyWith(
            color: brandNegativeColor,
          ),
        ),
        const SizedBox(height: spaceQuarter),
      ],
      const SizedBox(height: space2),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header(this.state);

  final InterestInitializedState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    final updatedAtString = formatUpdatedTime(state.updatedAt);
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(spaceHalf),
            child: InfoBanner(
              message: 'Cập nhật lúc: $updatedAtString',
              textStyle: textTheme.textStyle,
              backgroundColor: CupertinoColors.systemGrey5,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              right: spaceHalf,
              bottom: space1,
            ),
            child: ViewModeSwitcher(
              viewMode: state.viewMode,
              onViewModeChanged: (viewMode) {
                context.read<InterestCubit>().changeViewMode(viewMode);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Refresher extends StatelessWidget {
  const _Refresher(this.state);

  final InterestInitializedState state;

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverRefreshControl(
      refreshTriggerPullDistance: 200,
      onRefresh: () {
        return Future.delayed(const Duration(milliseconds: 500))
            .then(
              (value) =>
                  context.read<InterestCubit>().changeInterestType(state.type),
            )
            .then((value) => Future.delayed(const Duration(seconds: 2)));
      },
    );
  }
}
