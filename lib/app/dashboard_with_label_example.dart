import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';
import 'package:http/http.dart';

class DashboardWithLabelExample extends StatefulWidget {
  final String label;
  final InfluxDBApi api;

  DashboardWithLabelExample({@required this.api, this.label});

  @override
  _DashboardWithLabelExampleState createState() =>
      _DashboardWithLabelExampleState();
}

class _DashboardWithLabelExampleState extends State<DashboardWithLabelExample> {
  List<Card> cards = [];

  @override
  void initState() {
    super.initState();
    _loadGraphs();
  }

  Future _loadGraphs() async {
    await _graphsForDashboardsWithLabel();
    print("DING DONG 4");
    try {
      setState(() {});
    } catch (e) {
      print("Unable to set state - probably no longer visible; error: " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cards.length == 0) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return ListView.builder(
        itemCount: cards.length,
        itemBuilder: (BuildContext context, int index) {
          return cards[index];
        });
  }

  Future _graphsForDashboardsWithLabel() async {
    List<String> dashboardIds = await _getDashboardIdsWithLabel();
    List<dynamic> cellObjs = await _getCellObjects(dashboardIds: dashboardIds);

    cards = [];
    if (cellObjs != null) {
      List<Future<Card>> awaitCardObjs = [];
      for (dynamic cellObj in cellObjs) {
        awaitCardObjs.add(_executeQueries(cellObject: cellObj));
      }
      for (Future<Card> awaitCard in awaitCardObjs) {
        cards.add(await awaitCard);
      }
    }
  }

  Future<Card> _executeQueries({cellObject}) async {
    List<InfluxDBQuery> queries = [];
    List<dynamic> qs = cellObject["properties"]["queries"];
    List<Future> waitForQueries = [];
    for (dynamic q in qs) {
      queries.add(widget.api.query(q["text"]));
    }

    List<InfluxDBTable> allTables = [];
    queries.forEach((InfluxDBQuery query) {
      waitForQueries.add((() async {
        allTables.addAll(await query.execute());
      })());
    });

    await Future.wait(waitForQueries);

    return Card(
      child: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(10.0),
              child: Text(cellObject["name"])),
          Container(
            padding: EdgeInsets.all(10.0),
            constraints: BoxConstraints(maxHeight: 350.00),
            child: InfluxDBLineGraph(
              tables: allTables,
              colorScheme: InfluxDBColorScheme.fromAPIData(
                  colorData: cellObject["properties"]["colors"],
                  size: allTables.length),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>> _getCellObjects({List<String> dashboardIds}) async {
    List<dynamic> cellObjects = [];

    for (String dashboardId in dashboardIds) {
      String url = "${widget.api.influxDBUrl}/api/v2/dashboards/$dashboardId";
      url += "?org=${widget.api.org}";
      Response response = await get(
        url,
        headers: {
          "Authorization": "Token ${widget.api.token}",
          "Content-type": "application/json",
        },
      );
      if (response.statusCode != 200) {
        print(
            "WARNING: Failed to retrieve dashboard: $url ${response.statusCode}: ${response.body}");
      }
      List<dynamic> cells = json.decode(response.body)["cells"];

      // TODO: make all API calls in parallel
      cells.sort((a, b) => _cellPosition(a).compareTo(_cellPosition(b)));

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
        "${widget.api.influxDBUrl}/api/v2/dashboards/$dashboardId/cells/$cellId/view";
    url += "?orgID=${widget.api.org}";
    Response response = await get(
      url,
      headers: {
        "Authorization": "Token ${widget.api.token}",
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

    String url = "${widget.api.influxDBUrl}/api/v2/dashboards";
    url += "?org=${widget.api.org}";
    Response response = await get(
      url,
      headers: {
        "Authorization": "Token ${widget.api.token}",
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

  int _cellPosition(dynamic cell) {
    int result = 0;
    try {
      result = cell["y"] * 256 + cell["x"];
    } catch (e) {
      print("Unable to calculate cell position for sorting: " + e.toString());
    }
    return result;
  }
}
