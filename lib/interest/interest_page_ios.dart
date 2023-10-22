import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nono_finance/shared/colors.dart';
import 'package:nono_finance/shared/extension/data_ext.dart';
import 'package:nono_finance/shared/widget/cupertino_widget_util.dart';

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
                            type: type.label
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
    final textTheme = CupertinoTheme.of(context).textTheme;
    final updatedAtString = formatUpdatedTime(state.updatedAt);
    return CustomScrollView(
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () {
            return context
                .read<InterestCubit>()
                .changeInterestType(state.type)
                .then((value) => Future.delayed(const Duration(seconds: 2)));
          },
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: state.interestRatesByGroup.keys.length + 1,
            (context, itemIndex) {
              if (itemIndex == 0) {
                return Container(
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
                );
              }
              final index = itemIndex - 1;
              final group = state.interestRatesByGroup.keys.elementAt(index);
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
              return switch (state.type) {
                InterestType.onlineByBank ||
                InterestType.counterByBank =>
                  barData.isNotEmpty
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
                          valueSegmentTitleTextStyle:
                              textTheme.tabLabelTextStyle.copyWith(
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
                          height: barData.length * _horizontalBarBaseHeight +
                              totalNoteHeight,
                          groupNameStyle: textTheme.navTitleTextStyle,
                          barValueTextStyle: textTheme.tabLabelTextStyle,
                          notes: notes,
                        )
                      : const SizedBox.shrink()
              };
            },
          ),
        )
      ],
    );
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
      ]
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
