import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import 'dashboard.dart';
import 'error.dart';
import 'point.dart';
import 'query.dart';

class InfluxDBAPI {
  final String influxDBUrl;
  final String org;
  final String token;

  InfluxDBAPI(
      {@required this.influxDBUrl, @required this.org, @required this.token});

  InfluxDBQuery query(String queryString) {
    return InfluxDBQuery(api: this, queryString: queryString);
  }

  Future<List<InfluxDBDashboard>> dashboards() async {
    dynamic body = await _getJSONData("/api/v2/dashboards");
    return InfluxDBDashboard.fromAPIList(
        api: this, objects: body["dashboards"]);
  }

  Future<InfluxDBDashboardCell> dashboardCell(
      InfluxDBDashboardCellInfo cell) async {
    dynamic body = await _getJSONData(
        "/api/v2/dashboards/${cell.dashboard.id}/cells/${cell.id}/view");
    return InfluxDBDashboardCell.fromAPI(
        dashboard: cell.dashboard, object: body);
  }

  Future write(
      {@required InfluxDBPoint point, @required String bucket}) async {
    String url = "${_getURL("/api/v2/write")}&bucket=$bucket&precision=ns";

    Response response = await post(
      url,
      headers: {
        "Authorization": "Token $token"
      },
      body: point.lineProtocol,
    );
    print(url);
    print(response.request.headers);
    print(point.lineProtocol);
    print(response.statusCode);
    print(response.body);
    if (response.statusCode != 204) {
      _handleError(response);
    }
  }

  Future<String> postFluxQuery(String queryString) async {
    Response response = await post(
      _getURL("/api/v2/query"),
      headers: {
        "Authorization": "Token $token",
        "Accept": "application/csv",
        "Content-type": "application/vnd.flux",
      },
      body: queryString,
    );

    if (response.statusCode != 200) {
      _handleError(response);
    }

    return response.body;
  }

  String _getURL(urlSuffix) {
    String url = influxDBUrl;
    if (url[url.length - 1] == "/") {
      url = url.substring(0, url.length - 1);
    }

    url += urlSuffix;

    if (url.indexOf("?") >= 0) {
      url = url + "&org=$org";
    } else {
      url = url + "?org=$org";
    }
    return url;
  }

  Future<dynamic> _getJSONData(urlSuffix) async {
    Response response = await get(
      _getURL(urlSuffix),
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
    throw InfluxDBAPIHTTPError.fromResponse(response);
  }
}
