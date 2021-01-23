import './row.dart';

/// Individual table result from calling [InfluxDBAPI] and [InfluxDBQuery] API calls.
class InfluxDBTable {
  /// Column names for this table.
  List<String> keys;

  /// Resulting rows for this table.
  List<InfluxDBRow> rows = [];

  /// The name of the yield statement from the Flux query that produced the table;
  /// defaults to _result
  String yieldName;

  InfluxDBTable();

  /// Creates an instance of [InfluxDBTable] from raw CSV string returned by the query API call.
  InfluxDBTable.fromCSV({
      List<List<dynamic>> dataRows,
      this.keys,
      this.yieldName}) {
    // create the rows
    dataRows.forEach((List<dynamic> row) {
      InfluxDBRow newRow = InfluxDBRow.fromAPI(fields: row, keys: keys);
      this.rows.add(newRow);
    });
  }
}
