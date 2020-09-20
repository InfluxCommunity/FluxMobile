import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../api/row.dart';
import '../api/table.dart';
import 'color_scheme.dart';
import 'dashboard_cell_widget_axis.dart';

/// Widget for rendering a dashboard cell as a line chart.
class InfluxDBLineChartWidget extends StatefulWidget {
  /// [List] of [InfluxDBTable]s that this widget is showing information for.
  final List<InfluxDBTable> tables;

  /// Color scheme to use.
  final InfluxDBColorScheme colorScheme;

  /// Information about X axis.
  final InfluxDBDashboardCellWidgetAxis xAxis;

  /// Information about Y axis.
  final InfluxDBDashboardCellWidgetAxis yAxis;

  const InfluxDBLineChartWidget({
    Key key,
    @required this.tables,
    this.colorScheme,
    this.xAxis,
    this.yAxis,
  }) : super(key: key);
  @override
  _InfluxDBLineChartWidgetState createState() =>
      _InfluxDBLineChartWidgetState();
}

/// Widget state management for [InfluxDBDashboardCellWidget].
class _InfluxDBLineChartWidgetState extends State<InfluxDBLineChartWidget> {
  /// List of all lines to render in the line chart
  List<LineChartBarData> lines = [];

  /// Color scheme to use.
  InfluxDBColorScheme colorScheme;
  InfluxDBDashboardCellWidgetAxis xAxis;
  InfluxDBDashboardCellWidgetAxis yAxis;

  @override
  void initState() {
    super.initState();
    if (widget.colorScheme == null) {
      colorScheme = InfluxDBColorScheme(size: widget.tables.length);
    } else {
      colorScheme = widget.colorScheme;
    }

    widget.xAxis == null
        ? xAxis = InfluxDBDashboardCellWidgetAxis()
        : xAxis = widget.xAxis;
    widget.yAxis == null
        ? yAxis = InfluxDBDashboardCellWidgetAxis()
        : yAxis = widget.yAxis;
        
    colorScheme = colorScheme.withSize(widget.tables.length);
    _buildChart();
  }

  _buildChart() async {
    // execute each query and collect up the tables

    // each table becomes a line for the chart
    for (int i = 0; i < widget.tables.length; i++) {
      InfluxDBTable table = widget.tables[i];
      // get the line data from the table
      List<FlSpot> spots = [];
      for (InfluxDBRow row in table.rows) {
        try {
          double x = row.millisecondsSinceEpoch.toDouble();
          double y = double.parse(row.value.toString());

          // clipToBorder should handle this, but does not, so need must handle bounds
          if (widget.yAxis.maximum != null && y > widget.yAxis.maximum) {
            y = widget.yAxis.maximum;
          }
          if (widget.yAxis.minimum != null && y < widget.yAxis.minimum) {
            y = widget.yAxis.minimum;
          }
          spots.add(FlSpot(x, y));
        } catch (e) {
          print("Unable to parse row: " + e.toString());
        }
      }

      //format each line
      LineChartBarData lineData = LineChartBarData(
        spots: spots,
        dotData: FlDotData(show: false),
        colors: [colorScheme[i]],
        barWidth: 0.5,
      );

      lines.add(lineData);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (lines.length == 0) {
      return Center(child: CircularProgressIndicator());
    }

    SideTitles leftTitles = SideTitles(
      reservedSize: 40,
      showTitles: true,
      interval: widget.yAxis.interval,
      getTitles: widget.yAxis.getValueAsString,
    );

    FlTitlesData titlesData = FlTitlesData(
      show: true,
      leftTitles: leftTitles,
      bottomTitles: SideTitles(showTitles: false),
    );

    return Container(
      constraints: BoxConstraints.expand(),
      child: LineChart(
        LineChartData(
          titlesData: titlesData,
          minX: widget.xAxis.minimum,
          maxX: widget.xAxis.maximum,
          minY: widget.yAxis.minimum,
          maxY: widget.yAxis.maximum,
          lineBarsData: lines,
          borderData: FlBorderData(
            border: Border.all(color: Colors.grey, width: 2.0),
            show: true,
          ),
          gridData: FlGridData(
            show: false,
          ),
          backgroundColor: Colors.black,
        ),
      ),
    );
  }
}
