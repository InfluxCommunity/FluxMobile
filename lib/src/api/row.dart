import 'dart:collection';

import 'package:flutter/foundation.dart';

class InfluxDBRow extends ListBase<dynamic> {
  List<dynamic> _fields;
  List<String> keys;

  InfluxDBRow.fromList(
      {@required List<dynamic> fields, @required this.keys}) {
    _fields = fields;
  }

  dynamic get value {
    return _fields[keys.indexOf("_value")];
  }

  double get measurement {
    return double.parse(_fields[keys.indexOf("_measurement")].toString());
  }

  int get millisecondsSinceEpoch {
    return DateTime.parse(utcString).millisecondsSinceEpoch;
  }

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
