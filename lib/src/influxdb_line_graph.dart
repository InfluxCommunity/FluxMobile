import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';
import 'package:flux_mobile/src/influxdb_color_scheme.dart';
import 'package:flux_mobile/src/influxdb_row.dart';
import 'package:fl_chart/fl_chart.dart';

class InfluxDBLineGraph extends StatefulWidget {
  final List<InfluxDBTable> tables;
  final InfluxDBColorScheme colorScheme;

  const InfluxDBLineGraph({Key key, @required this.tables, this.colorScheme})
      : super(key: key);
  @override
  _InfluxDBLineGraphState createState() => _InfluxDBLineGraphState();

}

class _InfluxDBLineGraphState extends State<InfluxDBLineGraph> {
  String responseString = "initalizing ...";
  List<LineChartBarData> lines = [];
  InfluxDBColorScheme colorScheme;

  @override
  void initState() {
    super.initState();
    if (widget.colorScheme == null) {
      colorScheme = InfluxDBColorScheme(size: widget.tables.length);
    } else {
      colorScheme = widget.colorScheme;
    }
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
        spots.add(FlSpot(row.millisecondsSinceEpoch.toDouble(),
            double.parse(row.value.toString())));
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

    return Container(
      constraints: BoxConstraints.expand(),
      child: LineChart(
        LineChartData(
          lineBarsData: lines,
          gridData: FlGridData(
            show: false,
          ),
          backgroundColor: Colors.black,
          titlesData: FlTitlesData(
            bottomTitles: SideTitles(showTitles: false),
          ),
        ),
      ),
    );
  }
}
