import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'interest_bar_chart.dart';
import 'interest_cubit.dart';
import 'interest_state.dart';

class InterestPageIOS extends StatelessWidget {
  const InterestPageIOS({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InterestCubit()..init(),
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Interest page'),
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
                    itemCount: state.counterInterestByGroup.keys.length,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    itemBuilder: (context, index) {
                      final group =
                          state.counterInterestByGroup.keys.elementAt(index);
                      final rates = state.counterInterestByGroup[group]!;
                      final textTheme = CupertinoTheme.of(context).textTheme;
                      return InterestBarChart(
                        groupName: group,
                        rates: rates,
                        positiveColor: CupertinoColors.activeBlue,
                        negativeColor: CupertinoColors.destructiveRed,
                        axisColor: CupertinoColors.black,
                        axisGroupPadding: 48,
                        groupNameBottomPadding: 16,
                        minHeight: 400,
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
