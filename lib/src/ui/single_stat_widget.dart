import 'package:flutter/material.dart';
import '../api/table.dart';

/// Widget for rendering a set of tables as a line chart.
/// each tables is required to have a _time and _value column
class InfluxDBSingleStateWidget extends StatefulWidget {
  /// [List] of [InfluxDBTable]s that this widget is showing information for.
  final List<InfluxDBTable> tables;

  final dynamic colors;

  const InfluxDBSingleStateWidget({
    Key key,
    @required this.tables,
    this.colors,
  }) : super(key: key);
  @override
  _InfluxDBSingleStatWidgetState createState() =>
      _InfluxDBSingleStatWidgetState();
}

/// Widget state management for [InfluxDBDashboardCellWidget].
class _InfluxDBSingleStatWidgetState extends State<InfluxDBSingleStateWidget> {
  /// Color scheme to use.
  dynamic value;
  Color backgroundColor;

  @override
  void initState() {
    super.initState();
    _buildChart();
  }

  _buildChart() async {
    value = widget.tables[0].rows[0]["_value"];
    List<dynamic> colors = widget.colors;
    String hex = "#000000";
    colors.forEach((dynamic color) {
      if (value > color["value"]) {
        hex = color["hex"];
      }
    });
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) {
      hex = "FF" + hex;
    }
    backgroundColor = Color(
      int.parse("0x$hex"),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      color: backgroundColor,
      child: Center(
          child: Text(
        value.toString(),
        style: TextStyle(fontSize: 100.0),
      )),
    );
  }
}
