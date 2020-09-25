import 'dart:collection';

import 'package:flutter/foundation.dart';

/// Wrapper for querying the [InfluxDBAPI] and [InfluxDBQuery], providing standard fields as getters.
class InfluxDBRow extends ListBase<dynamic> {
  List<dynamic> _fields;

  /// List of keys available in the results
  List<String> keys;

  InfluxDBRow.fromList({@required List<dynamic> fields, @required this.keys}) {
    _fields = fields;
  }

  /// Value for this row.
  dynamic get value {
    return _fields[keys.indexOf("_value")];
  }

  dynamic get field {
    return _fields[keys.indexOf("_field")];
  }

  /// Measurement for this row.
  dynamic get measurement {
    return _fields[keys.indexOf("_measurement")];
  }

  /// Time associated with the row, as milliseconds.
  int get millisecondsSinceEpoch {
    return DateTime.parse(utcString).millisecondsSinceEpoch;
  }

  /// Time associated with the row, raw string.
  String get utcString {
    return _fields[keys.indexOf("_time")].toString();
  }

  @override
  int length;

  @override
  operator [](int index) {
    return _fields[index];
  }

  @override
  void operator []=(int index, value) {
    _fields[index] = value;
  }
}
