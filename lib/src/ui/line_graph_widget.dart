import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../api/row.dart';
import '../api/table.dart';
import 'color_scheme.dart';

class InfluxDBLineGraphWidget extends StatefulWidget {
  final List<InfluxDBTable> tables;
  final InfluxDBColorScheme colorScheme;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  const InfluxDBLineGraphWidget({
    Key key,
    @required this.tables,
    this.colorScheme,
    this.minX, this.maxX,
    this.minY, this.maxY,
  })
      : super(key: key);
  @override
  _InfluxDBLineGraphWidgetState createState() => _InfluxDBLineGraphWidgetState();
}

class _InfluxDBLineGraphWidgetState extends State<InfluxDBLineGraphWidget> {
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
          spots.add(FlSpot(row.millisecondsSinceEpoch.toDouble(),
              double.parse(row.value.toString())));
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
        getTitles: getValueAsString,
      );

    if (widget.minY != null && widget.maxY != null) {
      double diffY = widget.maxY - widget.minY;

      // TODO: improve calculations
      double interval = diffY / 10.0;

      leftTitles = SideTitles(
        reservedSize: 40,
        showTitles: true,
        interval: interval,
        getTitles: getValueAsString,
      );
   }

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
          minX: widget.minX,
          maxX: widget.maxX,
          minY: widget.minY,
          maxY: widget.maxY,
          lineBarsData: lines,
          gridData: FlGridData(
            show: false,
          ),
          backgroundColor: Colors.black,
        ),
      ),
    );
  }

  String getValueAsString(double value) {
    // TODO: implement approximations
    return '$value';
  }
}
