import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../api/row.dart';
import '../api/table.dart';
import 'color_scheme.dart';
import 'line_chart_axis.dart';

/// Widget for rendering a set of tables as a line chart.
/// each tables is required to have a _time and _value column
class InfluxDBLineChartWidget extends StatefulWidget {
  /// [List] of [InfluxDBTable]s that this widget is showing information for.
  final List<InfluxDBTable> tables;

  /// Color scheme to use.
  final InfluxDBColorScheme colorScheme;

  /// Information about X axis.
  final InfluxDBLineChartAxis xAxis;

  /// Information about Y axis.
  final InfluxDBLineChartAxis yAxis;

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
  InfluxDBLineChartAxis xAxis;
  InfluxDBLineChartAxis yAxis;

  bool dataChartable = true;

  @override
  void initState() {
    super.initState();
    if (widget.colorScheme == null) {
      colorScheme = InfluxDBColorScheme(size: widget.tables.length);
    } else {
      colorScheme = widget.colorScheme;
    }

    widget.xAxis == null
        ? xAxis = InfluxDBLineChartAxis()
        : xAxis = widget.xAxis;
    widget.yAxis == null
        ? yAxis = InfluxDBLineChartAxis()
        : yAxis = widget.yAxis;

//    colorScheme = widget.colorScheme.withSize(widget.tables.length);
    _buildChart();
  }

  _buildChart() async {
    // each table becomes a line for the chart
    for (int i = 0; i < widget.tables.length; i++) {
      InfluxDBTable table = widget.tables[i];
      // get the line data from the table
      List<FlSpot> spots = [];
      for (InfluxDBRow row in table.rows) {
        try {
          double x = row.millisecondsSinceEpoch.toDouble();
          double y = double.parse(row["_value"].toString());

          // clipToBorder should handle this, but does not, so need must handle bounds
          if (widget.yAxis.maximum != null && y > widget.yAxis.maximum) {
            y = widget.yAxis.maximum;
          }
          if (widget.yAxis.minimum != null && y < widget.yAxis.minimum) {
            y = widget.yAxis.minimum;
          }
          spots.add(FlSpot(x, y));
        } catch (e) {
          print("Unable to parse row (value: ${row["_value"]}): " + e.toString());
          dataChartable = false;
          break;
        }
      }

      //format each line
      LineChartBarData lineData = LineChartBarData(
        isStrokeCapRound: true,
        spots: spots,
        dotData: FlDotData(show: false),
        colors: [colorScheme[i]],
        barWidth: 3.0,
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
    if (!dataChartable) {
      return Center(
        child: Text(
            "The data contains strings for _value in at least one returned table, and therefore cannot be displayed in a line graph"),
      );
    }

    // build the Left axis
    SideTitles leftTitles = SideTitles(
      reservedSize: 40,
      showTitles: true,
      interval: widget.yAxis.interval,
      getTitles: widget.yAxis.getValueAsString,
    );

    // build the bottom axis
    FlTitlesData titlesData = FlTitlesData(
      show: true,
      leftTitles: leftTitles,
      bottomTitles: SideTitles(
          showTitles: false,
          rotateAngle: 90.0,
          reservedSize: 50.0,
          getTitles: (double value) {
            DateTime time =
                new DateTime.fromMillisecondsSinceEpoch(value.toInt());
            NumberFormat format = NumberFormat("00", "en_US");
            String t =
                "${format.format(time.day)}-${format.format(time.hour)}:${format.format(time.minute)}:${format.format(time.microsecond)}";
            return t;
          }),
    );

    return Container(
      constraints: BoxConstraints.expand(),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              maxContentWidth: 300.0,
              getTooltipItems: (List<LineBarSpot> spots) {
                return spots.map((barSpot) {
                  InfluxDBRow iRow = widget.tables[barSpot.barIndex].rows[0];
                  String t = "";
                  t += barSpot.y.toString() + ", ";
                  if (iRow.containsKey("_measurement") &&
                      iRow.containsKey("_field")) {
                    t += "${iRow["_measurement"]}, ${iRow["_field"]}, ";
                  } else {
                    if (iRow.containsKey("_measurement")) {
                      t += "${iRow["_measurement"]}, ";
                    }
                    if (iRow.containsKey("_field")) {
                      t += "${iRow["_field"]}, ";
                    }
                  }

                  iRow.keys.forEach((element) {
                    if (![
                      "_time",
                      "_start",
                      "_stop",
                      "table",
                      "result",
                      "_value",
                      "_measurement",
                      "_field"
                    ].contains(element)) {
                      t += "$element : ${iRow[element]} \n";
                    }
                  });

                  t += DateTime.fromMillisecondsSinceEpoch(barSpot.x.toInt())
                      .toString();
                  Color c = colorScheme[barSpot.barIndex];
                  return LineTooltipItem(
                      t, TextStyle(color: c, fontSize: 10.0));
                }).toList();
              },
            ),
          ),
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
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
