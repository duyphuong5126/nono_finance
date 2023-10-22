import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nono_finance/interest/interest_cubit.dart';
import 'package:nono_finance/interest/interest_data_descriptions.dart';
import 'package:nono_finance/shared/colors.dart';
import 'package:nono_finance/shared/dimens.dart';
import 'package:nono_finance/shared/extension/data_ext.dart';
import 'package:nono_finance/shared/widget/loading_body.dart';
import 'package:nono_finance/shared/widget/nono_icon.dart';

import '../shared/formatter/date_time_formatter.dart';
import '../shared/widget/chart/bar_chart/not_applicable_text.dart';
import '../shared/widget/info_banner.dart';
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
                InterestInitializedState() => state.type.title,
              };
              return Text(text);
            },
          ),
        ),
        body: BlocBuilder<InterestCubit, InterestState>(
          builder: (context, state) {
            return switch (state) {
              InterestInitialState() => const LoadingBody(),
              InterestInitializedState() => _InitializedBody(state)
            };
          },
        ),
      ),
    );
  }
}

const _barChartBaseHeight = 300.0;
const _horizontalBarBaseHeight = 30.0;
const _noteItemHeight = 10.0;

class _InitializedBody extends StatelessWidget {
  const _InitializedBody(this.state);

  final InterestInitializedState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
        itemCount: state.interestRatesByGroup.keys.length + 1,
        padding: const EdgeInsets.symmetric(vertical: space1),
        itemBuilder: (context, itemIndex) {
          if (itemIndex == 0) {
            final updatedAtString = formatUpdatedTime(state.updatedAt);
            return Container(
              padding: const EdgeInsets.only(
                left: spaceHalf,
                right: spaceHalf,
                bottom: space1,
              ),
              child: InfoBanner(
                message: 'Cập nhật lúc: $updatedAtString',
                textStyle: textTheme.bodyMedium,
                backgroundColor: Colors.grey[400]!,
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
              _generateChartNoteWidgets(textTheme, barData, description),
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
                      axisGroupPadding: 40,
                      groupNameBottomPadding: space1,
                      height: _barChartBaseHeight + totalNoteHeight,
                      groupNameStyle: textTheme.titleLarge,
                      barValueTextStyle: textTheme.bodySmall!,
                      valueSegmentTitleTextStyle:
                          textTheme.bodySmall?.copyWith(color: Colors.black),
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
                      axisColor: Colors.black,
                      height: barData.length * _horizontalBarBaseHeight +
                          totalNoteHeight,
                      groupNameStyle: textTheme.bodyLarge,
                      barValueTextStyle: textTheme.bodySmall!,
                      notes: notes,
                    )
                  : const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Iterable<Widget> _generateChartNoteWidgets(
    TextTheme textTheme,
    Map<String, double> barData,
    InterestDataDescriptions descriptions,
  ) {
    return [
      const SizedBox(height: space2),
      Text('* Đơn vị lãi suất: %/năm', style: textTheme.bodySmall),
      const SizedBox(height: spaceQuarter),
      Text('* KKH: Không kỳ hạn', style: textTheme.bodySmall),
      const SizedBox(height: spaceQuarter),
      if (descriptions.hasNA) ...[
        NotApplicableText(
          textStyle: textTheme.bodySmall,
          notApplicableColor: brandNegativeColor,
        ),
        const SizedBox(height: spaceQuarter),
      ],
      if (descriptions.hasMinMax) ...[
        Text(
          '* Lãi suất cao nhất',
          style: textTheme.bodySmall?.copyWith(color: brandPositiveColor),
        ),
        const SizedBox(height: spaceQuarter),
        Text(
          '* Lãi suất thấp nhất',
          style: textTheme.bodySmall?.copyWith(color: brandNegativeColor),
        ),
        const SizedBox(height: spaceQuarter),
      ]
    ];
  }

  Iterable<Widget> _generateHorizontalChartNoteWidgets(
    TextTheme textTheme,
    Map<String, double> barData,
    InterestDataDescriptions descriptions,
  ) {
    final hasNABar = barData.values
        .where((element) => element == double.negativeInfinity)
        .isNotEmpty;

    return [
      Text('* Đơn vị lãi suất: %/năm', style: textTheme.bodySmall),
      const SizedBox(height: spaceQuarter),
      Text('* KKH: Không kỳ hạn', style: textTheme.bodySmall),
      const SizedBox(height: spaceQuarter),
      if (hasNABar) ...[
        NotApplicableText(
          textStyle: textTheme.bodySmall,
        ),
        const SizedBox(height: spaceQuarter),
      ],
      if (descriptions.hasMinMax) ...[
        Text(
          '* Lãi suất cao nhất',
          style: textTheme.bodySmall?.copyWith(color: brandPositiveColor),
        ),
        const SizedBox(height: spaceQuarter),
        Text(
          '* Lãi suất thấp nhất',
          style: textTheme.bodySmall?.copyWith(color: brandNegativeColor),
        ),
        const SizedBox(height: spaceQuarter),
      ],
      const SizedBox(height: space2),
    ];
  }
}
