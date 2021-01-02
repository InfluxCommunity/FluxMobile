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

    // workaround for https://gitlab.com/rickspencer3/flux-mobile/-/issues/42
    // Remove extra header and row which should not be added in the first place
    // This kludge should not break even if #42 core bug gets fixed
    headers.remove("");
    tables[0].rows.forEach((InfluxDBRow row) {
      row.remove("");
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
          if (key != "") {
            cellWidgets.add(
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Center(
                  child: Tooltip(
                      message: "${row[key]}", child: Text("${row[key]}")),
                ),
              ),
            );
          }
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
