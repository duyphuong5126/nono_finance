import 'package:flutter/material.dart';
import 'package:nono_finance/shared/colors.dart';
import 'package:nono_finance/shared/dimens.dart';
import 'package:nono_finance/shared/widget/view_mode/view_mode.dart';

class ViewModeSwitcher extends StatelessWidget {
  const ViewModeSwitcher({
    super.key,
    required this.viewMode,
    required this.onViewModeChanged,
  });

  final ViewMode viewMode;
  final Function(ViewMode) onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    const borderColor = grey700;
    final isChart = viewMode == ViewMode.chart;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: const BorderRadius.all(Radius.circular(spaceQuarter)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: space1),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                onViewModeChanged(ViewMode.plainText);
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  top: spaceQuarter,
                  bottom: spaceQuarter,
                  right: space1,
                ),
                child: Icon(
                  Icons.text_snippet_outlined,
                  size: spaceOneHalf,
                  color: isChart ? Colors.grey[600] : null,
                ),
              ),
            ),
            Container(color: borderColor, width: 1),
            GestureDetector(
              onTap: () {
                onViewModeChanged(ViewMode.chart);
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  top: spaceQuarter,
                  bottom: spaceQuarter,
                  left: space1,
                ),
                child: Icon(
                  Icons.insert_chart,
                  size: spaceOneHalf,
                  color: !isChart ? Colors.grey[600] : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
