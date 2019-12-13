import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';

class DashboardWithLabelExample extends StatefulWidget {
  final String label;
  final InfluxDBApi api;

  DashboardWithLabelExample({@required this.api, this.label});

  @override
  _DashboardWithLabelExampleState createState() =>
      _DashboardWithLabelExampleState();
}

class _DashboardWithLabelExampleState extends State<DashboardWithLabelExample> {
  List<Card> cards;

  @override
  void initState() {
    super.initState();
    _loadGraphs();
  }

  Future _loadGraphs() async {
    await _graphsForDashboardsWithLabel();
    try {
      setState(() {});
    } catch (e) {
      print("Unable to set state - probably no longer visible; error: " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cards == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (cards.length == 0) {
      return Center(
        child: Text("No dashboards with \"mobile\" label were found"),
      );
    }

    return ListView.builder(
        itemCount: cards.length,
        itemBuilder: (BuildContext context, int index) {
          return cards[index];
        });
  }

  Future _graphsForDashboardsWithLabel() async {
    List<InfluxDBDashboard> dashboards = await _getDashboardsWithLabel();
    List<InfluxDBDashboardCell> cells = [];

    // toList() is needed and ensures that all async commands are called before iterating on them
    List<Future<List<InfluxDBDashboardCell>>> futures = dashboards.map((d) => d.cells()).toList();
    for (Future<List<InfluxDBDashboardCell>> future in futures) {
      cells.addAll(await future);
    }

    await _initializeCells(cells);
  }

  Future _initializeCells(List<InfluxDBDashboardCell> cells) async {
    cards = [];
    // toList() is needed and ensures that all async commands are called before iterating on them
    List<Future<Card>> futures = cells.map((c) => _initializeCell(c)).toList();
    for (Future<Card> future in futures) {
      cards.add(await future);
    }
  }

  Future<Card> _initializeCell(InfluxDBDashboardCell cell) async {
    List<InfluxDBTable> allTables = await cell.executeQueries();

    return Card(
      child: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(10.0),
              child: Text(cell.name)),
          Container(
            padding: EdgeInsets.all(10.0),
            constraints: BoxConstraints(maxHeight: 350.00),
            child: InfluxDBLineGraph(
              tables: allTables,
              colorScheme: InfluxDBColorScheme.fromAPIData(
                  colorData: cell.colors,
                  size: allTables.length),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<InfluxDBDashboard>> _getDashboardsWithLabel() async {
    List<InfluxDBDashboard> dashboards = await widget.api.dashboards();
    return dashboards.where((d) => d.labels.where((l) => l.name == "mobile").length > 0).toList();
  }
}
