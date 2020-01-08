import 'package:csv/csv.dart';

import './row.dart';

/// Individual table result from calling [InfluxDBAPI] and [InfluxDBQuery] API calls.
class InfluxDBTable {
  /// Column names for this table.
  List<String> keys;

  /// Resulting rows for this table.
  List<InfluxDBRow> rows = [];

  /// Creates an instance of [InfluxDBTable] from raw CSV string returned by the query API call.
  InfluxDBTable.fromCSV(String csv) {
    CsvToListConverter converter = CsvToListConverter();
    List<List<dynamic>> rowObjs = converter.convert(csv);

    keys = List<String>.from(rowObjs[0]);

    // delete the row of fieldnames
    rowObjs.removeAt(0);

    // create the rows
    rowObjs.forEach((List<dynamic> row) {
      rows.add(InfluxDBRow.fromList(fields: row, keys: keys));
    });
  }
}
