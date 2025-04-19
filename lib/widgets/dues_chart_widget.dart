import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../models/dues_chart_model.dart';

class DuesChartWidget extends StatelessWidget {
  final List<DuesChartItem> chartData;
  final String chartTitle;
  final String chartType;
  final bool isLoading;

  const DuesChartWidget({
    Key? key,
    required this.chartData,
    required this.chartTitle,
    required this.chartType,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (chartData.isEmpty) {
      return const Center(
        child: Text('No data available for chart'),
      );
    }

    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    );

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chartTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelRotation: chartType == 'top_members' ? 45 : 0,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  numberFormat: currencyFormat,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x : point.y',
                  header: '',
                ),
                series: <CartesianSeries>[
                  BarSeries<DuesChartItem, String>(
                    dataSource: chartData,
                    xValueMapper: (DuesChartItem data, _) => data.label,
                    yValueMapper: (DuesChartItem data, _) => data.totalDue,
                    name: 'Total Due',
                    color: Theme.of(context).primaryColor,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.outer,
                      textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    dataLabelMapper: (DuesChartItem data, _) =>
                        currencyFormat.format(data.totalDue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DuesPieChartWidget extends StatelessWidget {
  final List<DuesChartItem> chartData;
  final String chartTitle;
  final bool isLoading;

  const DuesPieChartWidget({
    Key? key,
    required this.chartData,
    required this.chartTitle,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (chartData.isEmpty) {
      return const Center(
        child: Text('No data available for chart'),
      );
    }

    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    );

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chartTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x : point.y',
                  header: '',
                ),
                series: <CircularSeries>[
                  DoughnutSeries<DuesChartItem, String>(
                    dataSource: chartData,
                    xValueMapper: (DuesChartItem data, _) => data.label,
                    yValueMapper: (DuesChartItem data, _) => data.totalDue,
                    name: 'Total Due',
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    dataLabelMapper: (DuesChartItem data, _) =>
                        currencyFormat.format(data.totalDue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
