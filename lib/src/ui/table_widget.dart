import 'package:flutter/material.dart';

import '../../influxDB.dart';

class InfluxDBTableWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<InfluxDBTable> tables;

  const InfluxDBTableWidget({Key key, this.properties, this.tables})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> headers = List<String>();
    List<String> fields = List<String>();

    List<dynamic> fieldOptions = properties["fieldOptions"];
    fieldOptions.forEach((dynamic field) {
      if (field["visible"] == true) {
        headers.add(field["displayName"]);
        fields.add(field["internalName"]);
      }
    });

    List<Widget> cellWidgets = List<Widget>();
    headers.forEach((element) {
      cellWidgets.add(
        Text(element),
      );
    });

    tables.forEach((InfluxDBTable table) {
      table.rows.forEach((InfluxDBRow row) {
        fields.forEach((String key) {
          cellWidgets.add(
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Center(
                child: Text("${row[key]}"),
              ),
            ),
          );
        });
      });
    });

    return GridView.count(
      crossAxisCount: headers.length,
      children: cellWidgets,
      childAspectRatio: 3,
    );
  }
}
