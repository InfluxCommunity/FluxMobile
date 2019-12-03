import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';
import 'package:flux_mobile/src/influxdb_color_scheme.dart';
import 'package:rapido/rapido.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'influxdb_chart.dart';

class DashboardCell extends StatefulWidget {
  final String cellId;
  final String dashboardId;

  final Document userDoc;

  const DashboardCell({Key key, this.cellId, this.userDoc, this.dashboardId})
      : super(key: key);

  _DashboardCellState createState() => _DashboardCellState();
}

class _DashboardCellState extends State<DashboardCell> {
  dynamic cellObj;
  List<InfluxDBTable> tables = [];

  @override
  void initState() {
    super.initState();
    _setDashboardCellData();
  }

  _setDashboardCellData() async {
    String url =
        "${widget.userDoc["url"]}/api/v2/dashboards/${widget.dashboardId}/cells/${widget.cellId}/view";
    url += "?orgID=${widget.userDoc["orgId"]}";
    Response response = await get(
      url,
      headers: {
        "Authorization": "Token ${widget.userDoc["token"]}",
        "Content-type": "application/json",
      },
    );
    if (response.statusCode != 200) {
      print(
          "WARNING: Failed to retrive cell: $url ${response.statusCode}: ${response.body}");
      return null;
    }
    cellObj = json.decode(response.body);
    await _executeQueries();
  }

  Future _executeQueries() async {
    List<InfluxDBQuery> queries = [];
    List<dynamic> qs = cellObj["properties"]["queries"];
    List<Future> waitForQueries = [];

    for (dynamic q in qs) {
      queries.add(
        InfluxDBQuery(
            queryString: q["text"],
            token: widget.userDoc["token"],
            influxDBUrl: widget.userDoc["url"],
            org: widget.userDoc["org"]),
      );

      queries.forEach((InfluxDBQuery query) {
        waitForQueries.add((() async {
          List<InfluxDBTable> ts = await query.execute();
          tables.addAll(ts);
        })());
      });
    }
    await Future.wait(waitForQueries);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (tables == [] || cellObj == null) {
      return Center(child: Text("Loading Cell ..."));
    }

    return Container(
      child: Card(
          child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(cellObj["name"]),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InfluxDBChart(
              tables: tables,
              colorScheme: InfluxDBColorScheme.fromAPIData(
                  size: tables.length,
                  colorData: cellObj["properties"]["colors"]),
            ),
          )
        ],
      )),
    );
  }
}
