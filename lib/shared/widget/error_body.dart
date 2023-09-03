import 'package:flutter/widgets.dart';

import '../dimens.dart';
import 'nono_icon.dart';

class ErrorBody extends StatelessWidget {
  const ErrorBody({
    super.key,
    required this.errorMessage,
    this.errorTextStyle,
  });

  final String errorMessage;
  final TextStyle? errorTextStyle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const NonoIcon(
            'assets/icon/ic_robot.svg',
            width: errorBodyIconSize,
            height: errorBodyIconSize,
          ),
          const SizedBox(height: space1),
          Text(
            errorMessage,
            style: errorTextStyle,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
