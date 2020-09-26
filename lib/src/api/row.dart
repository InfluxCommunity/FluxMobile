import 'dart:collection';

import 'package:flutter/foundation.dart';

/// Wrapper for querying the [InfluxDBAPI] and [InfluxDBQuery], providing standard fields as getters.
class InfluxDBRow extends MapBase<String, dynamic> {
  Map<String, dynamic> _map = {};

  InfluxDBRow.fromList({@required List<dynamic> fields, List<String> keys}) {
    keys.asMap().forEach((i, value) {
      if (value != null && value != "" && i > 0) {
        _map[value] = fields[i];
      }
    });
  }

  dynamic get field {
    return _map.containsKey("_field") ? _map["_field"] : null;
  }

  /// Measurement for this row.
  dynamic get measurement {
    return _map.containsKey("_measurement") ? _map["_measurement"] : null;
  }

  /// Time associated with the row, as milliseconds.
  int get millisecondsSinceEpoch {
    return DateTime.parse(utcString).millisecondsSinceEpoch;
  }

  /// Time associated with the row, raw string.
  String get utcString {
    return _map.containsKey("_time") ? _map["_time"].toString() : null;
  }

  @override
  int length;

  @override
  void clear() {
    _map.clear();
  }

  @override
  remove(Object key) {
    _map.remove(key);
  }

  @override
  operator [](Object key) {
    return _map[key];
  }

  @override
  void operator []=(String key, value) {
    _map[key] = value;
  }

  @override
  Iterable<String> get keys {
    return _map.keys;
  }
}
