import 'package:flutter/widgets.dart';

import '../dimens.dart';

const leftMargin = EdgeInsets.only(
  left: spaceHalf,
  right: spaceQuarter,
  bottom: spaceHalf,
);
const rightMargin = EdgeInsets.only(
  left: spaceQuarter,
  right: spaceHalf,
  bottom: spaceHalf,
);
const highlightPadding = EdgeInsets.symmetric(
  vertical: spaceHalf,
  horizontal: spaceQuarter,
);

class HighLightRow extends StatelessWidget {
  const HighLightRow({
    super.key,
    required this.firstData,
    required this.secondData,
    required this.firstColor,
    required this.secondColor,
    this.textStyle,
  });

  final String firstData;
  final String secondData;
  final Color firstColor;
  final Color secondColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: firstColor),
              borderRadius: const BorderRadius.all(Radius.circular(spaceHalf)),
            ),
            margin: leftMargin,
            padding: highlightPadding,
            child: Text(
              firstData,
              style: textStyle?.copyWith(color: firstColor),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: secondColor),
              borderRadius: const BorderRadius.all(Radius.circular(spaceHalf)),
            ),
            margin: rightMargin,
            padding: highlightPadding,
            child: Text(
              secondData,
              style: textStyle?.copyWith(color: secondColor),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
