import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';
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

  @override
  void initState() {
    super.initState();
    setDashboardCellData();
  }

  setDashboardCellData() async {
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
    setState(() {
      cellObj = json.decode(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cellObj == null) {
      return Center(child: Text("Loading Cell ..."));
    } else {
      List<InfluxDBQuery> queries = [];
      List<dynamic> qs = cellObj["properties"]["queries"];
      for (dynamic q in qs) {
        queries.add(
          InfluxDBQuery(
              queryString: q["text"],
              token: widget.userDoc["token"],
              influxDBUrl: widget.userDoc["url"],
              org: widget.userDoc["org"]),
        );
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
                queries: queries,
                colorScheme: cellObj["properties"]["colors"],
              ),
            )
          ],
        )),
      );
    }
  }
}
