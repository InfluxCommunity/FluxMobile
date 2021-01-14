import 'package:flutter/material.dart';
import 'package:flux_mobile/src/api/variables.dart';
import 'package:flux_mobile/src/ui/line_plus_single_stat_widget.dart';
import 'package:flux_mobile/src/ui/no_data_widget.dart';

import '../api/dashboard.dart';
import '../api/error.dart';
import '../api/table.dart';
import 'line_chart_widget.dart';
import 'color_scheme.dart';
import 'line_chart_axis.dart';
import 'single_stat_widget.dart';
import 'markdown_widget.dart';
import 'unsupported_cell_widget.dart';
import 'table_widget.dart';

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
      // will set tables property for cells without quieries (e.g. markdown) to and empty list
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
    //Trap unnamed cells
    String cellName = widget.cell.name == "Name this Cell"
        ? "Dashboard Cell"
        : widget.cell.name;

    return Column(
      children: <Widget>[
        Container(padding: EdgeInsets.all(10.0), child: Text(cellName)),
        Container(
          padding: EdgeInsets.all(10.0),
          constraints: BoxConstraints(minHeight: 350, maxHeight: 350.00),
          child: childWidget(),
        ),
      ],
    );
  }

  /// Renders the widget to show on the screen. It may be an instance of [InfluxDBLineChartWidget], an [InfluxDBTableWidget],
  /// an [InfluxDBMarkDownWidget] widget, or an [InfluxDBUnsupportedCellWidget],
  /// a [CircularProgressIndicator] while information about cell is being fetched or a [Text] showing an error.
  Widget childWidget() {
    if (errorString != null) {
      return Center(child: Text(errorString));
    }

    // display a spinning indicator while fetching queries
    if (allTables == null) {
      return Center(child: CircularProgressIndicator());
    }

    // Gaurd against cases where the query didn't return data
    if (allTables.length == 0 && widget.cell.queries.length > 0) {
      return InfluxDBNoDataCellWidget();
    }

    if (allTables.length > 0) {
      if (allTables[0].rows.length == 0 && widget.cell.queries.length > 0) {
        return InfluxDBNoDataCellWidget();
      }
    }

    switch (widget.cell.cellType) {
      case "xy":
        return _createLineGraphFromAPI();
      case "single-stat":
        return InfluxDBSingleStatWidget(
          tables: allTables,
          colorsAPIObj: widget.cell.colors,
        );
      case "line-plus-single-stat":
        return InfluxDBLinePlusSingleStateWidget(
          tables: allTables,
          colorsAPIObj: widget.cell.colors, lineChartWidget: _createLineGraphFromAPI(),
        );
      case "markdown":
        return InfluxDBMarkDownWidget(data: widget.cell.properties);
      case "table":
        return InfluxDBTableWidget.fromAPI(
            properties: widget.cell.properties, tables: allTables);
      default:
        return InfluxDBUnsupportedCellWidget(cellType: widget.cell.cellType);
    }
  }

  InfluxDBLineChartWidget _createLineGraphFromAPI() {
    InfluxDBLineChartAxis xAxis =
        InfluxDBLineChartAxis.fromCellAxis(widget.cell.xAxis);
    
    InfluxDBLineChartAxis yAxis =
        InfluxDBLineChartAxis.fromCellAxisAndTables(
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
