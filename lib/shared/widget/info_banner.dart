import 'package:flutter/widgets.dart';
import 'package:nono_finance/shared/dimens.dart';
import 'package:nono_finance/shared/widget/nono_icon.dart';

class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key, required this.message, this.textStyle});

  final String message;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const NonoIcon(
          'assets/icon/ic_info.svg',
          width: space1,
          height: space1,
        ),
        const SizedBox(width: spaceHalf),
        Text(message, style: textStyle),
      ],
    );
  }
}
