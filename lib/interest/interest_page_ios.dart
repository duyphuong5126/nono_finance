import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nono_finance/shared/extension/interest_type_ext.dart';
import 'package:nono_finance/shared/widget/cupertino_widget_util.dart';

import '../shared/dimens.dart';
import '../shared/widget/bar_chart_list_skeleton.dart';
import '../shared/widget/chart/bar_chart/nono_horizontal_bar_chart.dart';
import '../shared/widget/nono_icon.dart';
import '../shared/widget/chart/bar_chart/nono_bar_chart.dart';
import 'interest_cubit.dart';
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
                InterestInitializedState() => state.type.label,
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
                InterestInitialState() => const BarChartListSkeleton(
                    startColor: CupertinoColors.systemGrey,
                    endColor: CupertinoColors.systemGrey4,
                  ),
                InterestInitializedState() => ListView.builder(
                    clipBehavior: Clip.none,
                    itemCount: state.interestRatesByGroup.keys.length,
                    padding: const EdgeInsets.symmetric(vertical: space1),
                    itemBuilder: (context, index) {
                      final group =
                          state.interestRatesByGroup.keys.elementAt(index);
                      final rates = state.interestRatesByGroup[group]!;
                      final textTheme = CupertinoTheme.of(context).textTheme;
                      return switch (state.type) {
                        InterestType.onlineByBank ||
                        InterestType.counterByBank =>
                          rates.isNotEmpty
                              ? NonoBarChart(
                                  groupName: group,
                                  barData: rates,
                                  barColor: CupertinoColors.activeBlue,
                                  maxColor: CupertinoColors.activeGreen,
                                  minColor: CupertinoColors.destructiveRed,
                                  notApplicableColor:
                                      CupertinoColors.destructiveRed,
                                  axisGroupPadding: 48,
                                  groupNameBottomPadding: space1,
                                  chartBottomPadding: 48,
                                  minHeight: 340,
                                  groupNameStyle: textTheme.navTitleTextStyle,
                                  barValueTextStyle:
                                      textTheme.tabLabelTextStyle,
                                  noteTextStyle: textTheme.tabLabelTextStyle,
                                  valueSegmentTitleTextStyle:
                                      textTheme.tabLabelTextStyle.copyWith(
                                    color: CupertinoColors.black,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        InterestType.onlineByTerm ||
                        InterestType.counterByTerm =>
                          rates.isNotEmpty
                              ? NonoHorizontalBarChart(
                                  groupName: group,
                                  barData: rates,
                                  barColor: CupertinoColors.activeBlue,
                                  maxColor: CupertinoColors.activeGreen,
                                  minColor: CupertinoColors.destructiveRed,
                                  notApplicableColor:
                                      CupertinoColors.destructiveRed,
                                  axisColor: CupertinoColors.black,
                                  minHeight: 800,
                                  groupNameStyle: textTheme.navTitleTextStyle,
                                  barValueTextStyle:
                                      textTheme.tabLabelTextStyle,
                                  noteTextStyle: textTheme.tabLabelTextStyle,
                                )
                              : const SizedBox.shrink()
                      };
                    },
                  )
              };
            },
          ),
        ),
      ),
    );
  }
}
