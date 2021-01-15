import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flux_mobile/influxDB.dart';

class InfluxDBLinePlusSingleStateWidget extends StatelessWidget {
  final List<InfluxDBTable> tables;
  final InfluxDBLineChartWidget lineChartWidget;
  final dynamic colorsAPIObj;
  final int decimalPlaces;

  const InfluxDBLinePlusSingleStateWidget(
      {Key key,
      @required this.tables,
      this.colorsAPIObj,
      @required this.lineChartWidget,
      this.decimalPlaces})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(builder: (BuildContext context) {
          return lineChartWidget;
        }),
        OverlayEntry(builder: (BuildContext context) {
     
          return IgnorePointer(
            child: InfluxDBSingleStatWidget(
              colorsAPIObj: colorsAPIObj,
              tables: tables,
              fontColor: Colors.black,
              backgroundColor: Colors.white.withOpacity(0.0),
              decimalPlaces: decimalPlaces,
            ),
          );
        }),
      ],
    );
  }
}
