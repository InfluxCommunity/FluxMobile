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

    List<dynamic> colors = widget.cellProperties["colors"];
    int lineIndex = 0;

    queries.forEach((dynamic queryObj) async {
      _requestQueryResults(queryObj).then((Response response) {
        List<String> tables = _tablesFromResponse(response);

        tables.forEach((String table) {
          CsvToListConverter converter = CsvToListConverter();
          List<List<dynamic>> rows = converter.convert(table);

          if (rows.length != 0) {
            List keys = _extractAndRemoveKeysFromTable(rows);

            int valueColumn = keys.indexOf("_value");
            int timeColumn = keys.indexOf("_time");

            List<FlSpot> spots =
                _createLineDataFromTableRows(rows, timeColumn, valueColumn);

            dynamic color = colors[lineIndex];
            LineChartBarData lineChartBarData =
                _createBarData(spots, Color(_hexStringToHexInt(color["hex"])));
            setState(() {
              lines.add(lineChartBarData);
              lineIndex += 1;
            });
          }
        });
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

  List _extractAndRemoveKeysFromTable(List<List> rows) {
    List<dynamic> keys = rows[0];
    rows.removeAt(0);
    return keys;
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

  List<String> _tablesFromResponse(Response response) {
    String body = response.body;
    List<String> tables = body.split("\r\n\r\n");
    return tables;
  }

  Future<Response> _requestQueryResults(queryObj) async {
    String url = "${widget.userDoc["url"]}/api/v2/query";
    url += "?org=${widget.userDoc["org"]}";
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
          "WARNING Failed to execute query: ${response.request.url}}: ${response.statusCode}: ${response.body}");
      print(queryObj["text"]);
    }
    return response;
  }

  int _hexStringToHexInt(String hex) {
    hex = hex.replaceFirst('#', '');
    hex = hex.length == 6 ? 'ff' + hex : hex;
    int val = int.parse(hex, radix: 16);
    return val;
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
