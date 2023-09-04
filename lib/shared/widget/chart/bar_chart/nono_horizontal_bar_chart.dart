import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:collection/collection.dart';

import '../../../dimens.dart';
import 'bar_chart_util.dart';

class NonoHorizontalBarChart extends StatelessWidget {
  const NonoHorizontalBarChart({
    super.key,
    required this.groupName,
    required this.barData,
    required this.height,
    required this.barColor,
    required this.maxColor,
    required this.minColor,
    required this.axisColor,
    this.valueFormat,
    this.groupNameStyle,
    this.barValueTextStyle,
    this.barValueSteps = 5,
    this.notes = const [],
  });

  final String groupName;
  final Map<String, double> barData;
  final int barValueSteps;

  final Color barColor;
  final Color maxColor;
  final Color minColor;
  final Color axisColor;
  final double height;

  final TextStyle? groupNameStyle;
  final TextStyle? barValueTextStyle;

  final NumberFormat? valueFormat;

  final Iterable<Widget> notes;

  final double barWidth = 10;

  @override
  Widget build(BuildContext context) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: spaceHalf),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            groupName,
            style: groupNameStyle,
          ),
          Padding(
            padding: const EdgeInsets.only(top: spaceHalf),
            child: SizedBox(
              height: height,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(
                  minimum: minRange,
                  maximum: maxRange,
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
                    pointColorMapper:
                        (MapEntry<String, double> data, int index) {
                      final rate = data.value;
                      return rate == min
                          ? minColor
                          : rate == max
                              ? maxColor
                              : barColor;
                    },
                    color: barColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(5.0),
                      bottomRight: Radius.circular(5.0),
                    ),
                    dataLabelMapper: (MapEntry<String, double> data, _) =>
                        data.value > 0
                            ? (valueFormat
                                    ?.format(data.value)
                                    .replaceAll('.00', '') ??
                                data.value.toString())
                            : '—',
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.auto,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...notes,
        ],
      ),
    );
  }
}
