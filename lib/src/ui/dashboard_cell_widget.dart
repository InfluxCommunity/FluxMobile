import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../api/dashboard.dart';
import '../api/error.dart';
import '../api/table.dart';
import 'line_graph_widget.dart';
import 'color_scheme.dart';

class InfluxDBDashboardCellWidget extends StatefulWidget {
  final InfluxDBDashboardCell cell;

  const InfluxDBDashboardCellWidget({Key key, @required this.cell})
      : super(key: key);
  @override
  _InfluxDBDashboardCellWidgetState createState() => _InfluxDBDashboardCellWidgetState();
}

class _InfluxDBDashboardCellWidgetState extends State<InfluxDBDashboardCellWidget> {
  String responseString = "initalizing ...";
  List<LineChartBarData> lines = [];
  InfluxDBColorScheme colorScheme;

  List<InfluxDBTable> allTables;
  String errorString;

  @override
  void initState() {
    super.initState();
    _executeQueries();
  }

  _executeQueries() async {
    allTables = null;

    try {
      allTables = await widget.cell.executeQueries();
      errorString = null;
    } on InfluxDBAPIHTTPError catch (e) {
      errorString = e.readableMessage();
    }

    try {
      setState(() {});
    } on FlutterError catch (_) {
      // ignore - probably the cell is no longer visible
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
            padding: EdgeInsets.all(10.0),
            child: Text(widget.cell.name)),
        Container(
          padding: EdgeInsets.all(10.0),
          constraints: BoxConstraints(minHeight: 350, maxHeight: 350.00),
          child: childWidget(),
        ),
      ],
    );
  }

  Widget childWidget() {
    if (errorString != null) {
      return Center(child: Text(errorString));
    }

    if (allTables == null) {
      return Center(child: CircularProgressIndicator());
    }

    if (allTables.length == 0) {
      return Center(child: Text("No data for this cell has been retrieved"));
    }

    return InfluxDBLineGraphWidget(
      tables: allTables,
      minX: widget.cell.xAxis.minimum,
      maxX: widget.cell.xAxis.maximum,
      minY: widget.cell.yAxis.minimum,
      maxY: widget.cell.yAxis.maximum,
      colorScheme: InfluxDBColorScheme.fromAPIData(
          colorData: widget.cell.colors,
          size: allTables.length),
    );
  }
}
