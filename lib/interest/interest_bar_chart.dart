import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

class InterestBarChart extends StatelessWidget {
  const InterestBarChart({
    super.key,
    required this.groupName,
    required this.rates,
    required this.minHeight,
    required this.barColor,
    required this.notApplicableColor,
    required this.axisColor,
    required this.axisGroupPadding,
    required this.groupNameBottomPadding,
    required this.chartBottomPadding,
    this.groupNameStyle,
    this.noteTextStyle,
    this.barValueTextStyle,
  });

  final String groupName;
  final Map<String, double> rates;

  final Color barColor;
  final Color notApplicableColor;
  final Color axisColor;
  final double axisGroupPadding;
  final double minHeight;
  final double groupNameBottomPadding;
  final double chartBottomPadding;

  final TextStyle? groupNameStyle;
  final TextStyle? noteTextStyle;
  final TextStyle? barValueTextStyle;

  final double barWidth = 10;

  @override
  Widget build(BuildContext context) {
    int groupIndex = 0;
    final xAxisGroups = rates.keys;
    final hasNABar = rates.values
        .where((element) => element == double.negativeInfinity)
        .isNotEmpty;
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
                      final rate = rates[group] ?? 0.0;
                      final data = BarChartGroupData(
                        x: groupIndex,
                        barRods: [
                          BarChartRodData(
                            toY: rate > 0 ? rate : 0.0,
                            color: barColor,
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
                              child: Text(xAxisGroups.elementAt(value.toInt())),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final rate =
                              rates[xAxisGroups.elementAt(value.toInt())] ?? -1;
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
