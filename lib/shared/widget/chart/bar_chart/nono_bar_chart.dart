import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

import '../../../dimens.dart';
import 'bar_chart_util.dart';

class NonoBarChart extends StatelessWidget {
  const NonoBarChart({
    super.key,
    required this.groupName,
    required this.barData,
    required this.minHeight,
    required this.barColor,
    required this.maxColor,
    required this.minColor,
    required this.notApplicableColor,
    required this.axisGroupPadding,
    required this.groupNameBottomPadding,
    this.groupNameStyle,
    this.barValueTextStyle,
    this.valueSegmentTitleTextStyle,
    this.xAxisTextStyle,
    this.barValueSteps = 5,
    this.notes = const [],
  });

  final String groupName;
  final Map<String, double> barData;
  final int barValueSteps;

  final Color barColor;
  final Color maxColor;
  final Color minColor;
  final Color notApplicableColor;
  final double axisGroupPadding;
  final double minHeight;
  final double groupNameBottomPadding;

  final TextStyle? groupNameStyle;
  final TextStyle? barValueTextStyle;
  final TextStyle? valueSegmentTitleTextStyle;
  final TextStyle? xAxisTextStyle;

  final Iterable<Widget> notes;

  final double barWidth = 10;

  @override
  Widget build(BuildContext context) {
    int groupIndex = 0;
    final xAxisGroups = barData.keys;
    final values = barData.values.toList()..sort();
    final normalizedValues = values.whereNot((element) => element < 0);

    double min = normalizedValues.minOrNull ?? 0.0;
    double max = normalizedValues.maxOrNull ?? 0.0;
    double minRange = 0.0;
    double maxRange = max;
    final barInterval = calculateInterval(
      minRange,
      maxRange,
      barValueSteps,
    );
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.only(
        left: spaceHalf,
        right: spaceHalf,
        top: groupIndex > 0 ? space4 : 0.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            groupName,
            style: groupNameStyle,
          ),
          SizedBox(height: groupNameBottomPadding),
          AspectRatio(
            aspectRatio: 2,
            child: Padding(
              padding: const EdgeInsets.only(top: spaceHalf),
              child: BarChart(
                BarChartData(
                  barGroups: xAxisGroups.map(
                    (group) {
                      final rate = barData[group] ?? 0.0;
                      final data = BarChartGroupData(
                        x: groupIndex,
                        barRods: [
                          BarChartRodData(
                            toY: rate > 0 ? rate : 0.0,
                            color: rate == min
                                ? minColor
                                : rate == max
                                    ? maxColor
                                    : barColor,
                            width: barWidth,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(barWidth / 2),
                            ),
                          )
                        ],
                      );
                      groupIndex++;
                      return data;
                    },
                  ).toList(),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(width: 1),
                      left: BorderSide(width: 1),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return RotationTransition(
                            turns: const AlwaysStoppedAnimation(-45 / 360),
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: axisGroupPadding,
                              ),
                              child: Text(
                                xAxisGroups.elementAt(value.toInt()),
                                style: xAxisTextStyle,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value != meta.max ? value.toString() : '',
                            style: valueSegmentTitleTextStyle,
                          );
                        },
                        interval: barInterval > 0 ? barInterval : null,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final rate =
                              barData[xAxisGroups.elementAt(value.toInt())] ??
                                  -1;
                          return rate >= 0
                              ? Text(
                                  rate.toString(),
                                  style: barValueTextStyle,
                                )
                              : Text(
                                  "—",
                                  style: barValueTextStyle?.copyWith(
                                    color: notApplicableColor,
                                  ),
                                );
                        },
                      ),
                    ),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ),
          ...notes,
        ],
      ),
    );
  }
}
