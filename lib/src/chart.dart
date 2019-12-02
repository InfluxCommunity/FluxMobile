import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';
import 'package:flux_mobile/src/influxdb_row.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:rapido/rapido.dart';

class Chart extends StatefulWidget {
  final Document userDoc;
  final dynamic cellProperties;

  const Chart({Key key, @required this.userDoc, @required this.cellProperties})
      : super(key: key);
  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  String responseString = "initalizing ...";
  List<LineChartBarData> lines = [];

  @override
  void initState() {
    super.initState();
    _buildChart();
  }

  _buildChart() async {
    List<dynamic> queryObjs = widget.cellProperties["queries"];
    List<Color> colors = [];
    List<dynamic> cellColors = widget.cellProperties["colors"];
    List<InfluxDBTable> tables = [];

    // TODO: improve? map?
    cellColors.forEach((dynamic c) {
      colors.add(Color(_hexStringToHexInt(c["hex"])));
    });

    // execute each query and collect up the tables
    for (dynamic queryObj in queryObjs) {
      InfluxDBQuery query = InfluxDBQuery(
          queryString: queryObj["text"],
          influxDBUrl: widget.userDoc["url"],
          org: widget.userDoc["org"],
          token: widget.userDoc["token"]);

      List<InfluxDBTable> ts = await query.execute();
      tables.addAll(ts);
    }

    // each table becomes a line for the chart
    for (int i = 0; i < tables.length; i++) {
      InfluxDBTable table = tables[i];
      // get the line data from the table
      List<FlSpot> spots = [];
      for (InfluxDBRow row in table.rows) {
        spots.add(FlSpot(row.millisecondsSinceEpoch.toDouble(), double.parse(row.value.toString())));
      }

      //format each line
      LineChartBarData lineData = LineChartBarData(
        spots: spots,
        dotData: FlDotData(show: false),
        colors: [_intermediateColor(colors, i, tables.length)],
        barWidth: 0.5,
      );

      lines.add(lineData);
    }

    setState(() {});
  }

  int _hexStringToHexInt(String hex) {
    hex = hex.replaceFirst('#', '');
    hex = hex.length == 6 ? 'ff' + hex : hex;
    int val = int.parse(hex, radix: 16);
    return val;
  }

  Color _intermediateColor(
      List<Color> colors, int seriesIndex, int seriesCount) {
    if (seriesCount < 1 || colors.length < 2) {
      return colors[0];
    }
    double t = ((colors.length - 1.0) * seriesIndex) / seriesCount;
    int i = t.floor();
    if (i == colors.length - 1) {
      i -= 1;
    }
    return HSVColor.lerp(
      HSVColor.fromColor(colors[i]),
      HSVColor.fromColor(colors[i + 1]),
      t - i,
    ).toColor();
  }

  @override
  Widget build(BuildContext context) {
    if (lines.length == 0) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
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
