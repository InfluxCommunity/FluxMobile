import 'package:flutter/material.dart';
import 'package:rapido/rapido.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'chart.dart';

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
        "https://us-west-2-1.aws.cloud2.influxdata.com/api/v2/dashboards/${widget.dashboardId}/cells/${widget.cellId}/view";
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
    return Card(
        child: cellObj == null
            ? Center(child: Text("Loading Cell ..."))
            : Column(
                children: <Widget>[
                  Text(cellObj["name"]),
                  Chart(
                    userDoc: widget.userDoc,
                    queries: cellObj["queries"],
                  )
                ],
              ));
  }
}
