import 'package:flutter/foundation.dart';

import '../api/api.dart';
import './table.dart';

/// InfluxDB 2.0 query, using the Flux language as query syntax.
class InfluxDBQuery {
  /// Instance of [InfluxDBAPI] object for running the InfluxDB API calls.
  final InfluxDBAPI api;

  /// Query string to run.
  final String queryString;

  /// Tables with the result, only available after `execute` has been called.
  List<InfluxDBTable> tables = [];

  /// Creates a new instance of [InfluxDBQuery] using [InfluxDBAPI] for running the InfluxDB API and the query to run.
  InfluxDBQuery({@required this.api, @required this.queryString});

  /// Executes the query and returns a [Future] to [List] of [InfluxDBTable] objects.
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
