import 'package:flutter/foundation.dart';

import '../api/influxdb_api.dart';
import 'influxdb_table.dart';
import 'package:http/http.dart';

class InfluxDBQuery {
  final InfluxDBApi api;
  final String queryString;
  List<InfluxDBTable> tables = [];
  String errorString;

  InfluxDBQuery({@required this.api, @required this.queryString});

  Future<List<InfluxDBTable>> execute() async {
    // 1: Make the rest call
    String body = await api.postFluxQuery(queryString);
    //2: Parse the tables out of the CVS and reate InfluxDB Tables with each block
    body.split("\r\n\r\n").forEach((String part) {
      if (part.length > 2) {
        tables.add(InfluxDBTable.fromCSV(part));
      }
    });
    return tables;
  }
}
