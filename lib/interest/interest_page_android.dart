import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nono_finance/interest/interest_cubit.dart';

import 'interest_bar_chart.dart';
import 'interest_state.dart';

class InterestPageAndroid extends StatelessWidget {
  const InterestPageAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InterestCubit()..init(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Interest page'),
        ),
        body: BlocBuilder<InterestCubit, InterestState>(
          builder: (context, state) {
            return switch (state) {
              InterestInitialState() => const Text('Initializing'),
              InterestInitializedState() => ListView.builder(
                  clipBehavior: Clip.none,
                  itemCount: state.counterInterestByGroup.keys.length,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  itemBuilder: (context, index) {
                    final group =
                        state.counterInterestByGroup.keys.elementAt(index);
                    final rates = state.counterInterestByGroup[group]!;
                    final theme = Theme.of(context);
                    return InterestBarChart(
                      groupName: group,
                      rates: rates,
                      positiveColor: Colors.blue,
                      negativeColor: Colors.red,
                      axisColor: Colors.black,
                      axisGroupPadding: 40,
                      groupNameBottomPadding: 16,
                      minHeight: 350,
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
