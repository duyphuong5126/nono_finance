import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        child: Center(
          child: BlocBuilder<InterestCubit, InterestState>(
            builder: (context, state) {
              return switch (state) {
                InterestInitialState() => const Text('Initializing'),
                InterestInitializedState() => const Text('Initialized')
              };
            },
          ),
        ),
      ),
    );
  }
}
