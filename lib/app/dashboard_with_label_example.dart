import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';
import 'package:http/http.dart';

class DashboardWithLabelExample extends StatefulWidget {
  final String label;
  final String baseUrl;
  final String orgId;
  final String token;

  DashboardWithLabelExample({this.label, this.baseUrl, this.orgId, this.token});

  @override
  _DashboardWithLabelExampleState createState() =>
      _DashboardWithLabelExampleState();
}

class _DashboardWithLabelExampleState extends State<DashboardWithLabelExample> {
  List<InfluxDBLineGraph> graphs = [];
  
  @override
  void initState() {
    super.initState();
    _loadGraphs();
  }

  Future _loadGraphs() async {
    await _graphsForDashboardsWithLabel();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (graphs == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return ListView.builder(
      itemCount: graphs.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: Container(
              padding: EdgeInsets.all(10.0),
              constraints: BoxConstraints(maxHeight: 350.00),
              child: graphs[index]),
        );
      },
    );
  }

  Future _graphsForDashboardsWithLabel() async {
    List<String> dashboardIds = await _getDashboardIdsWithLabel();
    List<dynamic> cellObjs = await _getCellObjects(dashboardIds: dashboardIds);

    if (cellObjs != null) {
      cellObjs.forEach((dynamic cellObj) async {
        await _executeQueries(cellObject: cellObj);
      });
    }
  }

  Future _executeQueries({cellObject}) async {
    List<InfluxDBQuery> queries = [];
    List<dynamic> qs = cellObject["properties"]["queries"];
    List<Future> waitForQueries = [];
    for (dynamic q in qs) {
      queries.add(
        InfluxDBQuery(
            queryString: q["text"],
            token: widget.token,
            influxDBUrl: widget.baseUrl,
            org: widget.orgId),
      );

      queries.forEach((InfluxDBQuery query) {
        waitForQueries.add((() async {
          List<InfluxDBTable> tables = await query.execute();

          graphs.add(
            InfluxDBLineGraph(
              tables: tables,
              colorScheme: InfluxDBColorScheme.fromAPIData(
                  colorData: cellObject["properties"]["colors"],
                  size: tables.length),
            ),
          );
        })());
      });
    }
    await Future.wait(waitForQueries);
    setState(() {});
  }

  Future<List<dynamic>> _getCellObjects({List<String> dashboardIds}) async {
    List<dynamic> cellObjects = [];

    for (String dashboardId in dashboardIds) {
      String url = "${widget.baseUrl}/api/v2/dashboards/$dashboardId";
      url += "?orgID=${widget.orgId}";
      Response response = await get(
        url,
        headers: {
          "Authorization": "Token ${widget.token}",
          "Content-type": "application/json",
        },
      );
      if (response.statusCode != 200) {
        print(
            "WARNING: Failed to retrieve dashboard: $url ${response.statusCode}: ${response.body}");
      }
      List<dynamic> cells = json.decode(response.body)["cells"];
      for (dynamic cell in cells) {
        dynamic cellObj =
            await _getCellObject(cellId: cell["id"], dashboardId: dashboardId);
        cellObjects.add(cellObj);
      }
    }
    return cellObjects;
  }

  Future<dynamic> _getCellObject({String cellId, String dashboardId}) async {
    String url =
        "${widget.baseUrl}/api/v2/dashboards/$dashboardId/cells/$cellId/view";
    url += "?orgID=${widget.orgId}";
    Response response = await get(
      url,
      headers: {
        "Authorization": "Token ${widget.token}",
        "Content-type": "application/json",
      },
    );
    if (response.statusCode != 200) {
      print(
          "WARNING: Failed to retrive cell: $url ${response.statusCode}: ${response.body}");
      return null;
    }
    return json.decode(response.body);
  }

  Future<List<String>> _getDashboardIdsWithLabel() async {
    List<String> ids = [];

    String url = "${widget.baseUrl}/api/v2/dashboards";
    url += "?orgID=${widget.orgId}";
    Response response = await get(
      url,
      headers: {
        "Authorization": "Token ${widget.token}",
        "Content-type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var returnedObj = json.decode(response.body);
      List<dynamic> dashboardsObj = returnedObj["dashboards"];

      dashboardsObj.forEach((dynamic dashboardObj) {
        List<dynamic> labelsObjs = dashboardObj["labels"];
        for (dynamic labelObj in labelsObjs) {
          if (labelObj["name"] == widget.label) {
            ids.add(dashboardObj["id"]);
          }
        }
      });
    }
    return ids;
  }
}
