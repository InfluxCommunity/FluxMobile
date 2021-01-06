import 'package:flutter/material.dart';

import '../../influxDB.dart';

class InfluxDBTableWidget extends StatelessWidget {
  final Map<String, dynamic> properties = {};
  final List<InfluxDBTable> tables;

  InfluxDBTableWidget({Key key, this.tables});

  InfluxDBTableWidget.fromAPI(
      {Key key, final Map<String, dynamic> properties, this.tables})
      : super(key: key) {
    if (properties != null) {
      this.properties.addAll(properties);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> headers = tables[0].keys;
    List<String> fields = tables[0].keys;

    if (properties.length > 0) {
      // replace default headers and fields with those supplied by the API
      headers = [];
      fields = [];
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
    }

    return SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
          columns: headers.map((String key) {
            return DataColumn(
              label: Text(key),
            );
          }).toList(),
          rows: tables[0].rows.map((InfluxDBRow row) {
            return DataRow(
              cells: fields.map((String key) {
                return DataCell(
                  Text(
                    row[key].toString(),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
