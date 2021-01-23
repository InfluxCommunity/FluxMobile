import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flux_mobile/influxDB.dart';
import 'package:http/http.dart';

/// Represent a bucket in InfluxDB 2.0. 
class InfluxDBBucket {
  /// Required API object for fetching bucket data
  InfluxDBAPI api;

  /// The name of the bucket as defined in the InfluxDB org
  String name;

  /// The description of the bucket as defined in the InfluxDB org
  String description;

  /// The unique id created by InfluxDB at time of bucket creation
  String id;

  /// Creation date
  DateTime createdAt;

  /// Last edited date for bucket metadata, such as name, description, retention policy, etc...
  DateTime updatedAt;

  /// The retention period in seconds, if any
  int retentionSeconds;

  /// If false, then the bucket has an infinite retention policy. 
  bool hasRetentionPolicy;

  /// Cardinality for all of the data in the bucket. Note that this property is set
  /// asyncronously after the InfluxDBBucket constructor is called. Supply a function to
  /// onLoadComplete to respond this property being set.
  int cardinality;

  /// A list of the most recent records for each series in the bucket. Note that this property is set
  /// asyncronously after the InfluxDBBucket constructor is called. Supply a function to
  /// onLoadComplete to respond this property being set.
  List<InfluxDBTable> mostRecentRecords;

  /// The date of the most recent write on any series in the bucket. Note that this property is set
  /// asyncronously after the InfluxDBBucket constructor is called. Supply a function to
  /// onLoadComplete to respond this property being set.
  DateTime mostRecentWrite;

  /// Call back function for responding to async properties being set. This includes carinality,
  /// mostRecentRecords, and mostRecentWrite.
  Function onLoadComplete;

  /// Creates a bucket. However, this constructor will not populate the properteies of the object.
  /// Typically, use InfluxDBBucket.fromAPI() via the InfluxDBAPI.buckets() 
  /// function in order to create an instance of a bucket.
  InfluxDBBucket({@required this.api, this.name});

  /// Creates and returns a bucket based on JSON returned by the InfluxDB REST API.
  /// Note that some properties will be set asyncronously (after this function returns).
  /// Set the onLoadComplete function to respond when those properties are set.
  InfluxDBBucket.fromAPI(
      {@required this.api,
      @required Map<dynamic, dynamic> apiObj,
      this.onLoadComplete}) {
    setPropertiesFromAPIObj(apiObj);
  }

  /// For an existing InfluxDBBucket object, updates existing properties.
  /// Note that some properties will be set asyncronously (after this function returns).
  /// Set the onLoadComplete function to respond when those properties are set.
  setPropertiesFromAPIObj(Map<dynamic, dynamic> apiObj) async {
    id = apiObj["id"];
    name = apiObj["name"];
    description = apiObj["description"];
    createdAt = DateTime.parse(apiObj["createdAt"]);
    updatedAt = DateTime.parse(apiObj["updatedAt"]);
    if (apiObj["retentionRules"].length == 0) {
      hasRetentionPolicy = false;
      retentionSeconds = 0;
    } else {
      hasRetentionPolicy = true;
      retentionSeconds = apiObj["retentionRules"][0]["everySeconds"];
    }
    await Future.wait<void>([
      _setRecentWrites(),
      _setCardinality(),
    ]);
    if (onLoadComplete != null) onLoadComplete();
  }

  Future _setRecentWrites() async {
    String flux =
        "from(bucket: \"$name\") |> range(start: -100y) |> last() |> drop(columns: [\"_start\",\"_stop\",])";
    InfluxDBQuery query = InfluxDBQuery(api: api, queryString: flux);
    List<InfluxDBTable> tables = await query.execute();
    tables.sort((a, b) {
      return DateTime.parse(b.rows[0]["_time"])
          .compareTo(DateTime.parse(a.rows[0]["_time"]));
    });
    mostRecentRecords = tables;
    if (tables[0].rows != null && tables[0].rows.length > 0) {
      mostRecentWrite = DateTime.parse(tables[0].rows[0]["_time"]);
    }
  }

  Future _setCardinality() async {
    String flux = '''
    import "influxdata/influxdb"

    influxdb.cardinality(bucket: \"$name\", start: -100y) 
    ''';
    InfluxDBQuery query = InfluxDBQuery(api: api, queryString: flux);
    List<InfluxDBTable> tables = await query.execute();
    if (tables[0].rows.length > 0) {
      cardinality = tables[0].rows[0]["_value"];
    }
  }

  /// Resets all of the properties for an existing bucket object. 
  /// Note that some properties will be set asyncronously (after this function returns).
  /// Set the onLoadComplete function to respond when those properties are set.
  Future refresh() async {
    Response response = await get(
      api.getURI("/api/v2/buckets/${this.id}"),
      headers: {
        "Authorization": "Token ${api.token.toString()}",
        "Content-type": "application/json",
      },
    );
    if (response.statusCode != 200) {
      api.handleError(response);
    }
    setPropertiesFromAPIObj(
      json.decode(response.body),
    );
  }
}

// {
// "links": {},
// "id": "string",
// "type": "user",
// "name": "string",
// "description": "string",
// "orgID": "string",
// "rp": "string",
// "createdAt": "2019-08-24T14:15:22Z",
// "updatedAt": "2019-08-24T14:15:22Z",
// "retentionRules": [
// {
// "type": "expire",
// "everySeconds": 86400
// }
// ],
