import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NonoIcon extends StatelessWidget {
  const NonoIcon(
    this.iconName, {
    super.key,
    this.width,
    this.height,
    this.color,
  });

  final String iconName;
  final double? width;
  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      iconName,
      width: width,
      height: height,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}
