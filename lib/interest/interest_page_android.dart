import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nono_finance/interest/interest_cubit.dart';

import 'interest_bar_chart.dart';
import 'interest_state.dart';
import 'interest_type.dart';

class InterestPageAndroid extends StatelessWidget {
  const InterestPageAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InterestCubit()..init(),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<InterestCubit, InterestState>(
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
        body: BlocBuilder<InterestCubit, InterestState>(
          builder: (context, state) {
            return switch (state) {
              InterestInitialState() => const Text('Initializing'),
              InterestInitializedState() => ListView.builder(
                  clipBehavior: Clip.none,
                  itemCount: state.interestRatesByGroup.keys.length,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  itemBuilder: (context, index) {
                    final group =
                        state.interestRatesByGroup.keys.elementAt(index);
                    final rates = state.interestRatesByGroup[group]!;
                    final theme = Theme.of(context);
                    return InterestBarChart(
                      groupName: group,
                      rates: rates,
                      barColor: Colors.blue,
                      notApplicableColor: Colors.red,
                      axisColor: Colors.black,
                      axisGroupPadding: 40,
                      groupNameBottomPadding: 16,
                      chartBottomPadding: 32,
                      minHeight: 330,
                      groupNameStyle: theme.textTheme.bodyLarge,
                      barValueTextStyle: theme.textTheme.bodySmall!,
                      noteTextStyle: theme.textTheme.bodySmall,
                    );
                  },
                )
            };
          },
        ),
      ),
    );
  }
}
