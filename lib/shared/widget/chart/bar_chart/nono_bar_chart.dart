import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

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
    required this.chartBottomPadding,
    this.groupNameStyle,
    this.noteTextStyle,
    this.barValueTextStyle,
    this.valueSegmentTitleTextStyle,
    this.xAxisTextStyle,
    this.barValueSteps = 5,
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
  final double chartBottomPadding;

  final TextStyle? groupNameStyle;
  final TextStyle? noteTextStyle;
  final TextStyle? barValueTextStyle;
  final TextStyle? valueSegmentTitleTextStyle;
  final TextStyle? xAxisTextStyle;

  final double barWidth = 10;

  @override
  Widget build(BuildContext context) {
    int groupIndex = 0;
    final xAxisGroups = barData.keys;
    final hasNABar = barData.values.where((element) => element < 0).isNotEmpty;
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
        left: 8.0,
        right: 8.0,
        top: groupIndex > 0 ? 64.0 : 0.0,
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
              padding: const EdgeInsets.only(top: 8.0),
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
          SizedBox(height: chartBottomPadding),
          Text('* Đơn vị lãi suất: %/năm', style: noteTextStyle),
          const SizedBox(height: 4),
          Text('* KKH: Không kỳ hạn', style: noteTextStyle),
          const SizedBox(height: 4),
          if (hasNABar)
            _NotApplicableText(
              textStyle: noteTextStyle,
              notApplicableColor: notApplicableColor,
            ),
        ],
      ),
    );
  }
}

class _NotApplicableText extends StatelessWidget {
  const _NotApplicableText({
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
