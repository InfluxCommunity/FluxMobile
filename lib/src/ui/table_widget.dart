import 'package:flutter/material.dart';

import '../../influxDB.dart';

class InfluxDBTableWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<InfluxDBTable> tables;

  const InfluxDBTableWidget.fromAPI({Key key, this.properties, this.tables})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> headers = [];
    List<String> fields = [];

    List<dynamic> fieldOptions = properties["fieldOptions"];

    // The API returns all possible fields in fieldOptions, so
    // we need to prune the ones that aren't used
    List<dynamic> _fieldOptionsToDump = [];
    fieldOptions.forEach((dynamic fo) {
      if (tables.length > 0) {
        List<String> keys = tables[0].rows[0].keys.toList();
        if (!keys.contains(fo["internalName"])) {
          _fieldOptionsToDump.add(fo);
        }
      }
    });

    _fieldOptionsToDump.forEach((fo) {
      fieldOptions.remove(fo);
    });

    fieldOptions.forEach((dynamic field) {
      if (field["visible"] == true) {
        headers.add(field["displayName"]);
        fields.add(field["internalName"]);
      }
    });

    List<Widget> cellWidgets = [];
    headers.forEach((element) {
      cellWidgets.add(
        Center(
          child: Text(
            element,
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
