import 'package:flutter/material.dart';
import '../api/table.dart';

/// Widget for rendering a set of tables as a line chart.
/// each tables is required to have a _time and _value column
class InfluxDBSingleStatWidget extends StatefulWidget {
  /// [List] of [InfluxDBTable]s that this widget is showing information for.
  final List<InfluxDBTable> tables;

  final dynamic colorsAPIObj;
  final Color fontColor;
  final Color backgroundColor;

  /// Used to create single stat widgets from dashboard data.
  /// colorsAPIObj is used by the dashboards API to create SingleStatWidgets,
  /// and is not typically used directly. textColor and backgroundColor are ignored 
  /// if colorsAPIObj is supplied
  const InfluxDBSingleStatWidget(
      {Key key,
      @required this.tables,
      this.colorsAPIObj,
      this.fontColor,
      this.backgroundColor})
      : super(key: key);
  @override
  _InfluxDBSingleStatWidgetState createState() =>
      _InfluxDBSingleStatWidgetState();
}

/// Widget state management for [InfluxDBDashboardCellWidget].
class _InfluxDBSingleStatWidgetState extends State<InfluxDBSingleStatWidget> {
  /// Color scheme to use.
  dynamic value;
  Color backgroundColor = Colors.black;
  Color fontColor = Colors.white;

  @override
  void initState() {
    if(widget.backgroundColor != null){
      backgroundColor = widget.backgroundColor;
    }
    if(widget.fontColor != null){
      fontColor = widget.fontColor;
    }
    super.initState();
    _buildChart();
  }

  _buildChart() async {
    value = widget.tables[0].rows[0]["_value"];
    // figure out which color to apply

    if (widget.colorsAPIObj != null) {
      dynamic color;
      widget.colorsAPIObj.forEach((dynamic c) {
        if (value > c["value"]) {
          color = c;
        }
      });

      // apply the color
      String hex = "#000000";
      hex = color["hex"];

      hex = hex.replaceAll("#", "");
      if (hex.length == 6) {
        hex = "FF" + hex;
      }
      if (color["type"] == "text") {
        fontColor = Color(
          int.parse("0x$hex"),
        );
      } else {
        backgroundColor = Color(
          int.parse("0x$hex"),
        );
        fontColor = Colors.black;
      }
    }

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
        style: TextStyle(fontSize: 100.0, color: fontColor),
      )),
    );
  }
}
