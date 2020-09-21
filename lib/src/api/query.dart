import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';

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

  CsvToListConverter converter = CsvToListConverter();

  /// Executes the query and returns a [Future] to [List] of [InfluxDBTable] objects.
  Future<List<InfluxDBTable>> execute() async {
    String body = await api.postFluxQuery(queryString);

    List<String> currentKeys = List<String>();
    List<List<dynamic>> dataRows = List<List<dynamic>>();
    int currentTable = 0;

    List<List<dynamic>> allRows = converter.convert(body);

    allRows.forEach((List<dynamic> row) {
      if (row.length == 1) {
        tables.add(InfluxDBTable.fromCSV(dataRows, currentKeys));
        dataRows.clear();
      } else {
        if (row[2].runtimeType == String) {
          // ignore: unrelated_type_equality_checks
          if (row[2] == "table") {
            currentKeys = List<String>.from(row);
          }
        } else {
          print(row[2].runtimeType);
          if (row[2].runtimeType == int) {
            // ignore: unrelated_type_equality_checks
            if (row[2] == currentTable) {
              dataRows.add(row);
            } else {
              tables.add(InfluxDBTable.fromCSV(dataRows, currentKeys));
              dataRows.clear();
            }
          }
        }
      }
    });
    return tables;
  }
}
