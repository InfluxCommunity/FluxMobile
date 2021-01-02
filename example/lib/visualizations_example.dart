import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';

class VisualizationsListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    InfluxDBTable tableTable = InfluxDBTable();
    tableTable.keys = ["one", "two", "three"];
    for (int i = 0; i < 20; i++) {
      tableTable.rows.add(
        InfluxDBRow.fromList(
            fields: [i, i.toDouble(), i.toString() + " str"],
            keys: tableTable.keys),
      );
    }
    return ListView(
      // children: [InfluxDBTableWidget(tables: [tableTable],)],
       children: [Container(color: Colors.pink,)],
    );
  }
}
