import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

class InterestBarChart extends StatelessWidget {
  const InterestBarChart({
    super.key,
    required this.groupName,
    required this.rates,
    required this.minHeight,
    required this.positiveColor,
    required this.negativeColor,
    required this.axisColor,
    required this.axisGroupPadding,
    required this.groupNameBottomPadding,
    this.groupNameStyle,
    this.noteTextStyle,
    this.barValueTextStyle,
  });

  final String groupName;
  final Map<String, double> rates;

  final Color positiveColor;
  final Color negativeColor;
  final Color axisColor;
  final double axisGroupPadding;
  final double minHeight;
  final double groupNameBottomPadding;

  final TextStyle? groupNameStyle;
  final TextStyle? noteTextStyle;
  final TextStyle? barValueTextStyle;

  final double barWidth = 10;

  @override
  Widget build(BuildContext context) {
    int groupIndex = 0;
    final xAxisGroups = rates.keys;
    final hasNoNegativeBar =
        rates.values.where((element) => element < 0).isEmpty;
    final hasNoZeroOrPositiveBar =
        rates.values.where((element) => element >= 0).isEmpty;
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
                            toY: rate,
                            color: rate > 0 ? positiveColor : negativeColor,
                            width: barWidth,
                            borderRadius: rate > 0
                                ? BorderRadius.vertical(
                                    top: Radius.circular(barWidth / 2),
                                  )
                                : BorderRadius.vertical(
                                    bottom: Radius.circular(barWidth / 2),
                                  ),
                          )
                        ],
                      );
                      groupIndex++;
                      return data;
                    },
                  ).toList(),
                  gridData: FlGridData(
                    show: true,
                    checkToShowVerticalLine: (value) => false,
                    checkToShowHorizontalLine: (value) => value % 5 == 0,
                    getDrawingHorizontalLine: (value) {
                      final strokeWidth = value == 0 ? 1.0 : 0.0;
                      return FlLine(
                        strokeWidth: strokeWidth,
                        color: axisColor,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: hasNoNegativeBar || hasNoZeroOrPositiveBar,
                    border: const Border(bottom: BorderSide(width: 1)),
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
                          return Text(
                            rates[xAxisGroups.elementAt(value.toInt())]
                                .toString(),
                            style: barValueTextStyle,
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
          const SizedBox(height: 50),
          Wrap(
            children: [
              Text('* KKH: Không kỳ hạn', style: noteTextStyle),
              if (!hasNoZeroOrPositiveBar) ...[
                const SizedBox(width: 8),
                Text(
                  '* Lãi suất dương',
                  style: noteTextStyle?.copyWith(
                    color: positiveColor,
                  ),
                ),
              ],
              if (!hasNoNegativeBar) ...[
                const SizedBox(width: 8),
                Text(
                  '* Lãi suất âm',
                  style: noteTextStyle?.copyWith(
                    color: negativeColor,
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
