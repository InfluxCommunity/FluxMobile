import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flux_mobile/influxDB.dart';
import 'package:http/http.dart';

class InfluxDBBucket {
  InfluxDBAPI api;
  String name;
  String description;
  String id;
  String type;
  DateTime createdAt;
  DateTime updatedAt;
  int retentionSeconds;
  bool hasRetentionPolicy;
  DateTime mostRecentWrite;
  int cardinality;
  InfluxDBTable mostRecentRecord;

  InfluxDBBucket({@required this.api, this.name});

  InfluxDBBucket.fromAPI(
      {@required this.api, @required Map<dynamic, dynamic> apiObj}) {
    setPropertiesFromAPIObj(apiObj);
  }
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
      setRecentWrite(),
      setCardinality(),
    ]);
  }

  Future setRecentWrite() async {
    String flux =
        "from(bucket: \"$name\") |> range(start: -100y) |> group() |> last() |> drop(columns: [\"_start\",\"_stop\",])";
    InfluxDBQuery query = InfluxDBQuery(api: api, queryString: flux);
    List<InfluxDBTable> tables = await query.execute();
    if (tables[0].rows.length > 0) {
      mostRecentWrite = DateTime.parse(tables[0].rows[0]["_time"]);
      mostRecentRecord = tables[0];
    }
  }

  Future setCardinality() async {
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
    setPropertiesFromAPIObj(json.decode(response.body),);
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
