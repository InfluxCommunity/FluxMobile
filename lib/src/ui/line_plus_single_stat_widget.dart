import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flux_mobile/influxDB.dart';

class InfluxDBLinePlusSingleStateWidget extends StatelessWidget {
  final List<InfluxDBTable> tables;
  final InfluxDBLineChartWidget lineChartWidget;
  final colorsAPIObj;

  const InfluxDBLinePlusSingleStateWidget(
      {Key key,
      @required this.tables,
      this.colorsAPIObj,
      @required this.lineChartWidget})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(builder: (BuildContext context) {
          return lineChartWidget;
        }),
        OverlayEntry(builder: (BuildContext context) {
          InfluxDBTable lilTable = tables[0];
          InfluxDBRow row = lilTable.rows.last;
          lilTable.rows.clear();
          lilTable.rows.add(row);
          return IgnorePointer(
            child: InfluxDBSingleStatWidget(
              colorsAPIObj: colorsAPIObj,
              tables: [lilTable],
              fontColor: Colors.black,
              backgroundColor: Colors.white.withOpacity(0.0),
            ),
          );
        }),
      ],
    );
  }
}
