import './row.dart';

/// Individual table result from calling [InfluxDBAPI] and [InfluxDBQuery] API calls.
class InfluxDBTable {
  /// Column names for this table.
  List<String> keys;

  /// Resulting rows for this table.
  List<InfluxDBRow> rows = [];

  /// Creates an instance of [InfluxDBTable] from raw CSV string returned by the query API call.
  InfluxDBTable.fromCSV(List<List<dynamic>> dataRows, this.keys) {
 
    // create the rows
    dataRows.forEach((List<dynamic> row) {
    InfluxDBRow newRow = InfluxDBRow.fromList(fields: row, keys: keys);
    this.rows.add(newRow);
    });
  }
}
