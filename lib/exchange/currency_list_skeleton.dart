import 'package:flutter/widgets.dart';

import '../shared/dimens.dart';
import '../shared/widget/loading_color_builder.dart';

class CurrencyListSkeleton extends StatelessWidget {
  const CurrencyListSkeleton({
    super.key,
    required this.startColor,
    required this.endColor,
  });

  final Color startColor;
  final Color endColor;

  @override
  Widget build(BuildContext context) {
    return LoadingColorBuilder(
      builder: (context, color, child) {
        return ListView.separated(
          separatorBuilder: (context, index) {
            return const SizedBox(height: spaceHalf);
          },
          itemCount: 20,
          itemBuilder: (context, index) {
            return _LoadingItem(loadingColor: color!);
          },
        );
      },
      startColor: startColor,
      endColor: endColor,
    );
  }
}

class _LoadingItem extends StatelessWidget {
  const _LoadingItem({required this.loadingColor});

  final Color loadingColor;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: space1, horizontal: space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: loadingColor,
            height: space1,
            width: screenWidth / 2,
          ),
          Container(
            color: loadingColor,
            height: space1,
            width: screenWidth,
            margin: const EdgeInsets.only(top: spaceHalf),
          )
        ],
      ),
    );
  }
}
