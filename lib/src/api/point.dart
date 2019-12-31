import 'package:flutter/foundation.dart';
import 'error.dart';

/// A class that represents a point being written INTO InfluxDB.
/// Note that Points are written into InfluxDB, but Tables and
/// Rows are read from InfluxDB.
class Point {
  Map<String, dynamic> _tags = {};
  Map<String, dynamic> _fields = {};

  /// The measurement name for the point.
  final String measurement;

  /// The time stamp in nanoseconds for the point.
  /// If null, the InfluxDB server will set a timestamp when
  /// the point is written.
  int nanoseconds;

  /// Construct a point.
  /// Required fields are the measurement name
  /// and at least one field key/value pair.
  /// If nanoseconds is null and autoTimestamp is true,
  /// a timestamp will be created at the time the object is created.
  /// If a timestamp is supplied a autoTimestamp is true,
  /// An InfluxDBAPIError will be thrown.
  Point(
      {@required this.measurement,
      Map<String, dynamic> tags,
      @required Map<String, dynamic> fields,
      this.nanoseconds,
      bool autoTimestamp}) {
    if (nanoseconds == null && autoTimestamp == true) {
      nanoseconds = DateTime.now().microsecondsSinceEpoch * 1000;
    }
    if (nanoseconds != null && autoTimestamp == true) {
      throw InfluxDBAPIError(
          "AutoTimestamp cannot be true if a timestamp is supplied");
    }
    if (tags != null) this.tags = tags;
    _checkKeyNaming(fields);
    _fields = fields;
  }

  /// A String of InfluxDB line protocol.
  /// See https://v2.docs.influxdata.com/v2.0/reference/syntax/line-protocol/
  String get lineProtocol {
    return "$measurement ${_lineProtocolForTags()} ${_lineProtocolForFields()} $nanoseconds";
  }

  /// Optional tag set of key, value relationships.
  set tags(Map<String, dynamic> tags) {
    _checkKeyNaming(tags);
    _tags = tags;
  }

  Map<String, dynamic> get tags {
    return tags;
  }

  /// The field values supplied in the point.
  /// This value is read only
  Map<String, dynamic> get fields {
    return _fields;
  }

  void _checkKeyNaming(Map<String, dynamic> map) {
    map.forEach((String key, dynamic val) {
      if (key.startsWith("_")) {
        throw (InfluxDBAPIError(
            "Fields and tags must not start with underscore."));
      }
    });
  }

  String _lineProtocolForTags() {
    if (_tags == null || _tags.length == 0) {
      return "";
    }
    String t = "";
    _tags.forEach((String key, dynamic val) {
      t += ",$key=$val";
    });
    return t;
  }

  String _lineProtocolForFields() {
    if (_fields == null || _fields.length == 0) {
      return "";
    }
    String f = "";
    int i = 0;
    _fields.forEach((String key, dynamic val) {
      if (i > 0) {
        f += ",";
      }
      f += "$key=$val";
      i++;
    });
    return f;
  }
}
