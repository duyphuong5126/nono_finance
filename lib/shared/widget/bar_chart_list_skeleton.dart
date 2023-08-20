import 'dart:math';

import 'package:flutter/widgets.dart';

import '../dimens.dart';

class BarChartListSkeleton extends StatefulWidget {
  const BarChartListSkeleton({
    super.key,
    required this.startColor,
    required this.endColor,
  });

  final Color startColor;
  final Color endColor;

  @override
  State<BarChartListSkeleton> createState() => _BarChartListSkeletonState();
}

class _BarChartListSkeletonState extends State<BarChartListSkeleton> {
  bool _reverse = false;

  final List<double> _ratios = [];

  @override
  void initState() {
    super.initState();
    final random = Random();
    for (var i = 0; i < 5; i++) {
      _ratios.add(_heightRatio(random));
    }
  }

  @override
  Widget build(BuildContext context) {
    const maxHeight = 300.0;
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
        return ListView.separated(
          separatorBuilder: (context, index) {
            return const SizedBox(height: space2);
          },
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              constraints: const BoxConstraints.expand(height: maxHeight),
              margin: const EdgeInsets.symmetric(horizontal: space1),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: color!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _ratios
                    .map(
                      (ratio) => _SkeletonBar(
                        height: maxHeight * ratio,
                        barColor: color,
                      ),
                    )
                    .toList(),
              ),
            );
          },
        );
      },
    );
  }

  double _heightRatio(Random random) {
    final result = random.nextDouble();
    return result == 0.2
        ? 0.2
        : result == 1.0
            ? 0.9
            : result;
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
    required this.height,
    required this.barColor,
  });

  final double height;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: 20,
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(9.0),
          topLeft: Radius.circular(9.0),
        ),
      ),
    );
  }
}
