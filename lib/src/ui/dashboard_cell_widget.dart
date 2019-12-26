import 'package:flutter/material.dart';

import '../api/dashboard.dart';
import '../api/error.dart';
import '../api/table.dart';
import 'line_chart_widget.dart';
import 'color_scheme.dart';
import 'dashboard_cell_widget_axis.dart';

class InfluxDBDashboardCellWidget extends StatefulWidget {
  final InfluxDBDashboardCell cell;

  const InfluxDBDashboardCellWidget({Key key, @required this.cell})
      : super(key: key);
  @override
  _InfluxDBDashboardCellWidgetState createState() =>
      _InfluxDBDashboardCellWidgetState();
}

class _InfluxDBDashboardCellWidgetState
    extends State<InfluxDBDashboardCellWidget> {
  String responseString = "initalizing ...";
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
        Container(padding: EdgeInsets.all(10.0), child: Text(widget.cell.name)),
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

    InfluxDBDashboardCellWidgetAxis xAxis =
        InfluxDBDashboardCellWidgetAxis.fromCellAxis(widget.cell.xAxis);
    InfluxDBDashboardCellWidgetAxis yAxis =
        InfluxDBDashboardCellWidgetAxis.fromCellAxisAndTables(
            widget.cell.yAxis, allTables);

    return InfluxDBLineChartWidget(
      tables: allTables,
      xAxis: xAxis,
      yAxis: yAxis,
      colorScheme: InfluxDBColorScheme.fromAPIData(
          colorData: widget.cell.colors, size: allTables.length),
    );
  }
}
