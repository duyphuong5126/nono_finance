import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'interest_bar_chart.dart';
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
                InterestInitialState() => 'Initializing',
                InterestInitializedState() => switch (state.type) {
                    InterestType.counterByBank =>
                      'Lãi suất tại quầy theo ngân hàng',
                    InterestType.counterByTerm =>
                      'Lãi suất tại quầy theo kỳ hạn',
                    InterestType.onlineByBank =>
                      'Lãi suất online theo ngân hàng',
                    InterestType.onlineByTerm => 'Lãi suất online theo kỳ hạn',
                  },
              };
              return Center(child: Text(text));
            },
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<InterestCubit, InterestState>(
            builder: (context, state) {
              return switch (state) {
                InterestInitialState() => const Center(
                    child: Text('Initializing'),
                  ),
                InterestInitializedState() => ListView.builder(
                    clipBehavior: Clip.none,
                    itemCount: state.interestRatesByGroup.keys.length,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    itemBuilder: (context, index) {
                      final group =
                          state.interestRatesByGroup.keys.elementAt(index);
                      final rates = state.interestRatesByGroup[group]!;
                      final textTheme = CupertinoTheme.of(context).textTheme;
                      return InterestBarChart(
                        groupName: group,
                        rates: rates,
                        barColor: CupertinoColors.activeBlue,
                        notApplicableColor: CupertinoColors.destructiveRed,
                        axisColor: CupertinoColors.black,
                        axisGroupPadding: 48,
                        groupNameBottomPadding: 16,
                        chartBottomPadding: 48,
                        minHeight: 330,
                        groupNameStyle: textTheme.navTitleTextStyle,
                        barValueTextStyle: textTheme.tabLabelTextStyle,
                        noteTextStyle: textTheme.tabLabelTextStyle,
                      );
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
