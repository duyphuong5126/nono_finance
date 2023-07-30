import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nono_finance/interest/interest_cubit.dart';

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
              InterestInitializedState() => const Text('Initialized')
            };
          },
        ),
      ),
    );
  }
}
