import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:nono_finance/shared/widget/chart/bar_chart/double_bar_configs.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:collection/collection.dart';

import '../../../dimens.dart';
import 'bar_chart_util.dart';

class NonoHorizontalMultiBarChart extends StatelessWidget {
  const NonoHorizontalMultiBarChart({
    super.key,
    required this.height,
    required this.axisColor,
    required this.firstBarConfigsList,
    required this.secondBarConfigsList,
    required this.firstBarLabel,
    required this.secondBarLabel,
    required this.firstBarColor,
    required this.secondBarColor,
    this.valueFormat,
    this.yValueFormat,
    this.groupNameStyle,
    this.barValueTextStyle,
    this.barValueSteps = 5,
    this.notes = const [],
  });

  final List<SingleBarConfigs> firstBarConfigsList;
  final List<SingleBarConfigs> secondBarConfigsList;
  final String firstBarLabel;
  final String secondBarLabel;
  final Color firstBarColor;
  final Color secondBarColor;
  final int barValueSteps;

  final Color axisColor;
  final double height;

  final TextStyle? groupNameStyle;
  final TextStyle? barValueTextStyle;

  final NumberFormat? valueFormat;
  final NumberFormat? yValueFormat;

  final Iterable<Widget> notes;

  final double barWidth = 10;

  @override
  Widget build(BuildContext context) {
    final values = <double>[];
    values.addAll(firstBarConfigsList.map((e) => e.yValue));
    values.addAll(secondBarConfigsList.map((e) => e.yValue));

    final normalizedValues = values.whereNot((element) => element < 0);

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
                  numberFormat: yValueFormat,
                ),
                series: <ChartSeries<SingleBarConfigs, String>>[
                  BarSeries<SingleBarConfigs, String>(
                    dataSource: firstBarConfigsList,
                    xValueMapper: (SingleBarConfigs data, _) => data.xLabel,
                    yValueMapper: (SingleBarConfigs data, _) =>
                        data.yValue > 0 ? data.yValue : 0.0,
                    pointColorMapper: (_, __) {
                      return firstBarColor;
                    },
                    name: firstBarLabel,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(spaceHalf),
                      bottomRight: Radius.circular(spaceHalf),
                    ),
                    dataLabelMapper: (SingleBarConfigs data, _) =>
                        data.yValue > 0
                            ? (valueFormat
                                    ?.format(data.yValue)
                                    .replaceAll('.00', '') ??
                                data.yValue.toString())
                            : '—',
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.auto,
                      margin: EdgeInsets.only(left: space1),
                    ),
                    width: 0.8,
                    spacing: 0.2,
                  ),
                  BarSeries<SingleBarConfigs, String>(
                    dataSource: secondBarConfigsList,
                    xValueMapper: (SingleBarConfigs data, _) => data.xLabel,
                    yValueMapper: (SingleBarConfigs data, _) =>
                        data.yValue > 0 ? data.yValue : 0.0,
                    pointColorMapper: (_, __) {
                      return secondBarColor;
                    },
                    name: secondBarLabel,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(spaceHalf),
                      bottomRight: Radius.circular(spaceHalf),
                    ),
                    dataLabelMapper: (SingleBarConfigs data, _) =>
                        data.yValue > 0
                            ? (valueFormat
                                    ?.format(data.yValue)
                                    .replaceAll('.00', '') ??
                                data.yValue.toString())
                            : '—',
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.auto,
                    ),
                    width: 0.8,
                    spacing: 0.2,
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
