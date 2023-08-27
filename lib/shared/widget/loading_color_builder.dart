import 'package:flutter/widgets.dart';

class LoadingColorBuilder extends StatefulWidget {
  const LoadingColorBuilder({
    super.key,
    required this.builder,
    required this.startColor,
    required this.endColor,
  });

  final Color startColor;
  final Color endColor;
  final Widget Function(BuildContext, Color?, Widget?) builder;

  @override
  State<LoadingColorBuilder> createState() => _LoadingColorBuilderState();
}

class _LoadingColorBuilderState extends State<LoadingColorBuilder> {
  bool _reverse = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: ColorTween(
        begin: _reverse ? widget.endColor : widget.startColor,
        end: _reverse ? widget.startColor : widget.endColor,
      ),
      onEnd: () async {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            _reverse = !_reverse;
          });
        }
      },
      duration: const Duration(seconds: 5),
      builder: (context, color, child) {
        return widget.builder(context, color, child);
      },
    );
  }
}
