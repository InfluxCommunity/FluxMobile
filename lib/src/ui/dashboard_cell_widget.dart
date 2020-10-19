import 'package:flutter/material.dart';

import '../api/dashboard.dart';
import '../api/error.dart';
import '../api/table.dart';
import 'line_chart_widget.dart';
import 'color_scheme.dart';
import 'dashboard_line_chart_widget_axis.dart';
import 'single_stat_widget.dart';

/// Widget for showing an InfluxDB dashboard cell, using data from [InfluxDBDashboardCell].
class InfluxDBDashboardCellWidget extends StatefulWidget {
  /// Cell that this widget is showing information for.
  final InfluxDBDashboardCell cell;

  const InfluxDBDashboardCellWidget({Key key, @required this.cell})
      : super(key: key);
  @override
  _InfluxDBDashboardCellWidgetState createState() =>
      _InfluxDBDashboardCellWidgetState();
}

/// Widget state management for [InfluxDBDashboardCellWidget].
class _InfluxDBDashboardCellWidgetState
    extends State<InfluxDBDashboardCellWidget> {
  /// Color scheme to use for the widget.
  InfluxDBColorScheme colorScheme;

  /// List of all tables with data, retrieved after results from all cell queries are fetched.
  List<InfluxDBTable> allTables;

  /// Error string that will be shown in the UI if it is not set to `null`
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

  /// Renders the widget to show on the screen. It may be an instance of [InfluxDBLineChartWidget],
  /// a [CircularProgressIndicator] while information about cell is being fetched or a [Text] showing an error.
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

    if (widget.cell.cellType == "xy") {
      InfluxDBLineChartWidgetAxis xAxis =
          InfluxDBLineChartWidgetAxis.fromCellAxis(widget.cell.xAxis);

      InfluxDBLineChartWidgetAxis yAxis =
          InfluxDBLineChartWidgetAxis.fromCellAxisAndTables(
              widget.cell.yAxis, allTables);

      return InfluxDBLineChartWidget(
        tables: allTables,
        xAxis: xAxis,
        yAxis: yAxis,
        colorScheme: InfluxDBColorScheme.fromAPIData(
            colorData: widget.cell.colors, size: allTables.length),
      );
    } else {
      return InfluxDBSingleStateWidget(
        tables: allTables,
        colors: widget.cell.colors,
      );
    }
  }
}
