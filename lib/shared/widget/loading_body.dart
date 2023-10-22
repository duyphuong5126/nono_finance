import 'package:flutter/widgets.dart';

import '../dimens.dart';

class LoadingBody extends StatelessWidget {
  const LoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        "assets/gif/ic_loading_light_24dp.gif",
        height: loadingIconSize,
        width: loadingIconSize,
      ),
    );
  }
}
