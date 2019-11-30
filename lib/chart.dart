import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:rapido/rapido.dart';

class Chart extends StatefulWidget {
  final Document userDoc;
  final List<String> queries;

  const Chart({Key key, this.userDoc, this.queries})
      : super(key: key);
  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  String responseString = "initalizing ...";
  List<List<FlSpot>> lineSpots = [];

  @override
  void initState() {
    super.initState();
    getDataSync();
  }

  getDataSync() async {
    String url = "https://us-west-2-1.aws.cloud2.influxdata.com/api/v2/query";
    url += "?org=${widget.userDoc["org"]}";

    widget.queries.forEach((String query) async {
      List<Map<String, dynamic>> lineData = [];
      Response response = await post(
        url,
        headers: {
          "Authorization": "Token ${widget.userDoc["token"]}",
          "Accept": "application/csv",
          "Content-type": "application/vnd.flux",
        },
        body:
            "from (bucket: \"air-5m\") |> range(start: -2d, stop: -1d) |> yield()",
      );

      setState(() {
        CsvToListConverter converter = CsvToListConverter();
        List<List<dynamic>> rows = converter.convert(response.body);
        List<dynamic> keys = rows[0];
        print("************");
        print(keys);

        rows.removeAt(0);
        int measurementColumn = keys.indexOf("_measurement");
        List<FlSpot> spots = [];
        rows.forEach((List<dynamic> row) {
           spots.add(FlSpot(0, row[measurementColumn]));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
    // if (rowsAsListOfValues == []) {
    //   return Text("nada");
    // } else {
    //   List<FlSpot> spots = [];
    //   double i = 1.0;
    //   rowsAsListOfValues.forEach((List<dynamic> row) {
    //     if (i != 1.0) {
    //       try {
    //         double y = double.parse(row[6].toString());
    //         spots.add(FlSpot(i, y));
    //       } catch (Exception) {}
    //     }
    //     i++;
    //   });
    //   LineChartData chartOptions = LineChartData(
    //     lineBarsData: [
    //       LineChartBarData(
    //           spots: spots,
    //           dotData: FlDotData(show: false),
    //           colors: [Colors.green],
    //           barWidth: 0.5,
    //           belowBarData: BarAreaData(show: true, colors: [
    //             Colors.green.withOpacity(.4),
    //           ])),
    //     ],
    //     gridData: FlGridData(
    //         drawVerticalGrid: true,
    //         verticalInterval: 100.0,
    //         horizontalInterval: 1.0),
    //     backgroundColor: Colors.black,
    //     titlesData: FlTitlesData(
    //       bottomTitles: SideTitles(showTitles: false),
    //     ),
    //   );

    //   return Container(
    //     constraints: BoxConstraints.expand(),
    //     child: LineChart(
    //       chartOptions,
    //     ),
    //   );
    // }
  }
}
