import 'package:flutter/foundation.dart';

import 'influxdb_table.dart';
import 'package:http/http.dart';

class InfluxDBQuery {
  final String queryString;
  final String influxDBUrl;
  final String org;
  final String token;
  List<InfluxDBTable> tables = [];

  InfluxDBQuery(
      {@required this.queryString,
      @required this.influxDBUrl,
      @required this.org,
      @required this.token});

  Future<List<InfluxDBTable>> execute() async {
    // 1: Make the rest call
    String url = "$influxDBUrl/api/v2/query";
    url += "?org=$org";

    Response response = await post(
      url,
      headers: {
        "Authorization": "Token $token",
        "Accept": "application/csv",
        "Content-type": "application/vnd.flux",
      },
      body: queryString,
    );

    // Double check that the response worked
    if (response.statusCode != 200) {
      throw ("Failed to execute query: ${response.body}");
    }
    //2: Parse the tables out of the CVS and reate InfluxDB Tables with each block
    response.body.split("\r\n\r\n").forEach((String part) {
      if (part.length > 2) {
        tables.add(InfluxDBTable.fromCSV(part));
      }
    });
    return tables;
  }
}
