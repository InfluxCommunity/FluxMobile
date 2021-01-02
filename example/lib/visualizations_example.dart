import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';

class VisualizationsListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    InfluxDBTable tableTable = InfluxDBTable();
    tableTable.keys = ["one", "two", "three"];
    for (int i = 0; i < 20; i++) {
      Map<String, dynamic> rowData = {
        "one": i,
        "two": i.toDouble(),
        "three": i.toString() + " str"
      };

      tableTable.rows.add(
        InfluxDBRow(
          rowData,
        ),
      );
    }

    InfluxDBTable singleStatTable = InfluxDBTable();
    singleStatTable.keys = ["_value"];
    singleStatTable.rows.add(
      InfluxDBRow(
        {"_value": 0.01},
      ),
    );

    return ListView(
      children: [
        Container(
          height: 300.0,
          child: InfluxDBTableWidget(
            tables: [tableTable],
          ),
        ),
        Container(
          height: 300.0,
          child: InfluxDBSingleStatWidget(
            tables: [singleStatTable],
          ),
        ),
        Container(
          height: 300.0,
          child: InfluxDBSingleStatWidget(
            tables: [singleStatTable],
            fontColor: Colors.pink,
            backgroundColor: Colors.purple,
          ),
        ),
      ],
    );
  }
}
