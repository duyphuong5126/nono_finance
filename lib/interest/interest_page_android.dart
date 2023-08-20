import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nono_finance/interest/interest_cubit.dart';
import 'package:nono_finance/shared/dimens.dart';
import 'package:nono_finance/shared/extension/interest_type_ext.dart';
import 'package:nono_finance/shared/widget/bar_chart_list_skeleton.dart';
import 'package:nono_finance/shared/widget/nono_icon.dart';

import '../shared/widget/material_widget_util.dart';
import '../shared/widget/chart/bar_chart/nono_bar_chart.dart';
import 'interest_state.dart';
import 'interest_type.dart';
import '../shared/widget/chart/bar_chart/nono_horizontal_bar_chart.dart';

class InterestPageAndroid extends StatelessWidget {
  const InterestPageAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InterestCubit()..init(),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            BlocBuilder<InterestCubit, InterestState>(
              builder: (context, state) {
                return switch (state) {
                  InterestInitialState() => const SizedBox.shrink(),
                  InterestInitializedState() => IconButton(
                      padding: EdgeInsets.zero,
                      icon: const NonoIcon(
                        'assets/icon/ic_swap.svg',
                        width: actionBarIconSize,
                        height: actionBarIconSize,
                      ),
                      onPressed: () {
                        showActionsModalPopup(
                          context: context,
                          selectedAction: state.type,
                          title: 'Chọn danh mục',
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
            )
          ],
          title: BlocBuilder<InterestCubit, InterestState>(
            builder: (context, state) {
              final text = switch (state) {
                InterestInitialState() => 'Đang tải...',
                InterestInitializedState() => 'Lãi suất',
              };
              return Text(text);
            },
          ),
        ),
        body: BlocBuilder<InterestCubit, InterestState>(
          builder: (context, state) {
            return switch (state) {
              InterestInitialState() => BarChartListSkeleton(
                  startColor: Colors.grey[800]!,
                  endColor: Colors.grey[400]!,
                ),
              InterestInitializedState() => _InitializedBody(state)
            };
          },
        ),
      ),
    );
  }
}

class _InitializedBody extends StatelessWidget {
  const _InitializedBody(this.state);

  final InterestInitializedState state;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      edgeOffset: 0.0,
      onRefresh: () async {
        return context
            .read<InterestCubit>()
            .changeInterestType(state.type)
            .then((value) => Future.delayed(const Duration(seconds: 2)));
      },
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        itemCount: state.interestRatesByGroup.keys.length,
        padding: const EdgeInsets.symmetric(vertical: space1),
        itemBuilder: (context, index) {
          final group = state.interestRatesByGroup.keys.elementAt(index);
          final rates = state.interestRatesByGroup[group]!;
          final theme = Theme.of(context);
          return switch (state.type) {
            InterestType.onlineByBank ||
            InterestType.counterByBank =>
              rates.isNotEmpty
                  ? NonoBarChart(
                      groupName: group,
                      barData: rates,
                      barColor: Colors.blue,
                      maxColor: Colors.green,
                      minColor: Colors.red,
                      notApplicableColor: Colors.red,
                      axisGroupPadding: 40,
                      groupNameBottomPadding: space1,
                      chartBottomPadding: space2,
                      minHeight: 330,
                      groupNameStyle: theme.textTheme.bodyLarge,
                      barValueTextStyle: theme.textTheme.bodySmall!,
                      noteTextStyle: theme.textTheme.bodySmall,
                      valueSegmentTitleTextStyle:
                          theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black,
                      ),
                    )
                  : const SizedBox.shrink(),
            InterestType.onlineByTerm ||
            InterestType.counterByTerm =>
              rates.isNotEmpty
                  ? NonoHorizontalBarChart(
                      groupName: group,
                      barData: rates,
                      barColor: Colors.blue,
                      maxColor: Colors.green,
                      minColor: Colors.red,
                      notApplicableColor: Colors.red,
                      axisColor: Colors.black,
                      minHeight: 800,
                      groupNameStyle: theme.textTheme.bodyLarge,
                      barValueTextStyle: theme.textTheme.bodySmall!,
                      noteTextStyle: theme.textTheme.bodySmall,
                    )
                  : const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
