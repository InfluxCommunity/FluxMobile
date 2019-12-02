import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:csv/csv.dart';
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
    List<dynamic> queries = widget.cellProperties["queries"];
    List<Color> colors = [];
    List<dynamic> cellColors = widget.cellProperties["colors"];
    // TODO: improve? map?
    cellColors.forEach((dynamic c) {
      colors.add(Color(_hexStringToHexInt(c["hex"])));
    });

    List<List<List<dynamic>>> series = await _getAllQueries(queries);

    setState(() {
      int seriesMax = series.length - 1;
      int seriesIdx = 0;
      series.forEach((List<List<dynamic>> rows) {
        Map<String, int> fieldMap = new Map<String, int>();
        int colIndex = 0;

        rows[0].forEach((dynamic field) {
          fieldMap[field.toString()] = colIndex;
          colIndex += 1;
        });
        rows.removeAt(0);

        List<FlSpot> spots = _createLineDataFromTableRows(
          rows, fieldMap["_time"], fieldMap["_value"]
        );

        if (spots.length > 0) {
          LineChartBarData lineChartBarData = _createBarData(
            spots, _intermediateColor(colors, seriesIdx, seriesMax)
          );
          lines.add(lineChartBarData);
        }

        seriesIdx += 1;
      });
    });
  }

  LineChartBarData _createBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      dotData: FlDotData(show: false),
      colors: [color],
      barWidth: 0.5,
    );
  }

  List<FlSpot> _createLineDataFromTableRows(
      List<List> rows, int timeColumn, int valueColumn) {
    List<FlSpot> spots = [];
    rows.forEach((List<dynamic> row) {
      try {
        _addFlSpotFromRow(row, timeColumn, valueColumn, spots);
      } catch (Exception) {}
    });
    return spots;
  }

  void _addFlSpotFromRow(
      List row, int timeColumn, int valueColumn, List<FlSpot> spots) {
    DateTime t = DateTime.parse(row[timeColumn]);
    double time = double.parse(t.millisecondsSinceEpoch.toString());
    double value = double.parse(row[valueColumn].toString());
    spots.add(
      FlSpot(time, value),
    );
  }

  int _hexStringToHexInt(String hex) {
    hex = hex.replaceFirst('#', '');
    hex = hex.length == 6 ? 'ff' + hex : hex;
    int val = int.parse(hex, radix: 16);
    return val;
  }

  Future<List<List<List<dynamic>>>> _getAllQueries(List<dynamic> queries) async {
    String url = "https://us-west-2-1.aws.cloud2.influxdata.com/api/v2/query";
    url += "?org=${widget.userDoc["org"]}";

    List<List<List<dynamic>>> result = [];
    List<Future> waitFor = [];
    queries.forEach((dynamic queryObj) {
      waitFor.add((() async {
      Response response = await post(
        url,
        headers: {
          "Authorization": "Token ${widget.userDoc["token"]}",
          "Accept": "application/csv",
          "Content-type": "application/vnd.flux",
        },
        body: queryObj["text"],
      );
      if (response.statusCode != 200) {
        print(
            "WARNING Failed to execute query: $url: ${response.statusCode}: ${response.body}");
        print(queryObj["text"]);
      } else {
        response.body.split("\r\n\r\n").forEach((String part) {
          CsvToListConverter converter = CsvToListConverter();
          List<List<dynamic>> rows = converter.convert(part);
          if (rows.length >= 2) {
            result.add(rows);
          }
        });
      }
      })());
    });

    await Future.wait(waitFor);

    return result;
  }

  Color _intermediateColor(List<Color> colors, int seriesIndex, int seriesCount) {
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
      HSVColor.fromColor(colors[i+1]),
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
