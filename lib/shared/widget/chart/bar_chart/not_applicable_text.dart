import 'package:flutter/widgets.dart';

class NotApplicableText extends StatelessWidget {
  const NotApplicableText({
    super.key,
    required this.textStyle,
    required this.notApplicableColor,
  });

  final TextStyle? textStyle;
  final Color notApplicableColor;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: '* ',
        style: textStyle,
        children: [
          TextSpan(
            text: '—',
            style: textStyle?.copyWith(
              color: notApplicableColor,
            ),
          ),
          TextSpan(
            text: ': Không có thông tin',
            style: textStyle,
          )
        ],
      ),
    );
  }
}
