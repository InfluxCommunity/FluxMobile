import 'package:flutter/foundation.dart';

import 'influxdb_query.dart';

class InfluxDBApi {
  final String influxDBUrl;
  final String org;
  final String token;

  InfluxDBApi(
      {@required this.influxDBUrl,
      @required this.org,
      @required this.token});

  InfluxDBQuery query(String queryString) {
    return InfluxDBQuery(
      queryString: queryString,
      influxDBUrl: influxDBUrl,
      org: org,
      token: token,
    );
  }
}
