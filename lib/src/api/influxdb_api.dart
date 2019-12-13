import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import 'influxdb_dashboard.dart';
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

  Future<List<InfluxDBDashboard>> dashboards() async {
    dynamic body = await _getJSONData("/api/v2/dashboards");
    return InfluxDBDashboard.fromAPIList(api: this, objects: body["dashboards"]);
  }

  Future<InfluxDBDashboardCell> dashboardCell(InfluxDBDashboardCellInfo cell) async {
    dynamic body = await _getJSONData("/api/v2/dashboards/${cell.dashboard.id}/cells/${cell.id}/view");
    return InfluxDBDashboardCell.fromAPI(dashboard: cell.dashboard, object: body);
  }

  Future<dynamic> _getJSONData(urlSuffix) async {
    // TODO: remove trailing / in influxDBUrl if provided
    String url = "$influxDBUrl$urlSuffix?org=$org";
    Response response = await get(
      url,
      headers: {
        "Authorization": "Token $token",
        "Content-type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      dynamic body = json.decode(response.body);
      return body;
    } else {
      _handleError(response);
    }
  }

  _handleError(Response response) {
    // TODO: provide real error handling and possibly multiple classes for convenient catching
    throw("HTTP ERROR - TODO - IMPROVE");
  }
}
