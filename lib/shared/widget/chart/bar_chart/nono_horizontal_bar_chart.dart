import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:collection/collection.dart';

import 'bar_chart_util.dart';

class NonoHorizontalBarChart extends StatelessWidget {
  const NonoHorizontalBarChart({
    super.key,
    required this.groupName,
    required this.barData,
    required this.minHeight,
    required this.barColor,
    required this.notApplicableColor,
    required this.axisColor,
    this.groupNameStyle,
    this.noteTextStyle,
    this.barValueTextStyle,
    this.barValueSteps = 5,
  });

  final String groupName;
  final Map<String, double> barData;
  final int barValueSteps;

  final Color barColor;
  final Color notApplicableColor;
  final Color axisColor;
  final double minHeight;

  final TextStyle? groupNameStyle;
  final TextStyle? noteTextStyle;
  final TextStyle? barValueTextStyle;

  final double barWidth = 10;

  @override
  Widget build(BuildContext context) {
    final hasNABar = barData.values
        .where((element) => element == double.negativeInfinity)
        .isNotEmpty;
    final values = barData.values.toList()..sort();
    final normalizedValues = values.whereNot((element) => element < 0);
    final avg = normalizedValues.isNotEmpty ? normalizedValues.average : 0.0;

    double min = values.firstOrNull ?? 0.0;
    if (min < 0) {
      min = 0.0;
    }
    double max = values.lastOrNull ?? 0.0;
    if (max < 0) {
      max = 0.0;
    }
    final barInterval = calculateInterval(
      min,
      max + (avg / values.length),
      barValueSteps,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            groupName,
            style: groupNameStyle,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              height: minHeight,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(
                  minimum: min,
                  maximum: max,
                  interval: barInterval,
                ),
                series: <ChartSeries<MapEntry<String, double>, String>>[
                  BarSeries<MapEntry<String, double>, String>(
                    dataSource: barData.entries.toList(),
                    xValueMapper: (MapEntry<String, double> data, _) =>
                        data.key,
                    yValueMapper: (MapEntry<String, double> data, _) =>
                        data.value > 0 ? data.value : 0.0,
                    name: groupName,
                    color: barColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(5.0),
                      bottomRight: Radius.circular(5.0),
                    ),
                    dataLabelMapper: (MapEntry<String, double> data, _) =>
                        data.value > 0 ? data.value.toString() : '—',
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.auto,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text('* Đơn vị lãi suất: %/năm', style: noteTextStyle),
          const SizedBox(height: 4),
          Text('* KKH: Không kỳ hạn', style: noteTextStyle),
          const SizedBox(height: 4),
          if (hasNABar)
            _NotApplicableText(
              textStyle: noteTextStyle,
              notApplicableColor: notApplicableColor,
            ),
          const SizedBox(height: 32),
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
