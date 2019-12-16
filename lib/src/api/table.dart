import 'package:csv/csv.dart';

import './row.dart';

class InfluxDBTable {
  List<String> keys;
  List<InfluxDBRow> rows = [];

  InfluxDBTable.fromCSV(String csv) {
    CsvToListConverter converter = CsvToListConverter();
    List<List<dynamic>> rowObjs = converter.convert(csv);

    keys = List<String>.from(rowObjs[0]);

    // delete the row of fieldnames
    rowObjs.removeAt(0);

    // create the rows
    rowObjs.forEach((List<dynamic> row){
        rows.add(InfluxDBRow.fromList(fields:row, keys:keys));
    });
  }
}
