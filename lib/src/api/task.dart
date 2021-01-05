import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flux_mobile/influxDB.dart';
import 'package:http/http.dart';

class InfluxDBTask {
  final String name;
  final String id;
  String description;
  bool active;
  TaskSuccess lastRunSucceeded;
  String errorString;
  String queryString;
  DateTime latestCompleted;
  DateTime createdAt;
  DateTime updatedAt;
  InfluxDBAPI api;

  InfluxDBTask(
      {@required this.name,
      @required this.id,
      this.description,
      this.active,
      this.lastRunSucceeded,
      this.errorString,
      this.queryString,
      this.latestCompleted,
      this.createdAt,
      this.updatedAt,
      this.api});

  /// set the task to enabled by setting enabled to true or
  /// disabled by setting enabled to false.
  /// setEnabled will return the new status
  Future<bool> setEnabled({bool enabled}) async {
    Response response = await patch(
      api.getURI("/api/v2/tasks/${this.id}"),
      headers: {
        "Authorization": "Token ${api.token.toString()}",
        "Content-type": "application/json",
      },
      body: json.encode(
        {"status": enabled ? "active" : "inactive"},
      ),
    );
    if (response.statusCode != 200) {
      api.handleError(response);
    }
    Map<dynamic, dynamic> responseObj = json.decode(response.body);
    this.active = responseObj["status"] == "active";
    return (responseObj["status"] == "active");
  }
}

enum TaskSuccess { Failed, Succeeded, Canceled }

// Fields available from the API:
// "id": "string",
// "type": "string",
// "orgID": "string",
// "org": "string",
// "name": "string",
// "description": "string",
// "status": "active",
// "labels": [],
// "authorizationID": "string",
// "flux": "string",
// "every": "string",
// "cron": "string",
// "offset": "string",
// "latestCompleted": "2019-08-24T14:15:22Z",
// "lastRunStatus": "failed",
// "lastRunError": "string",
// "createdAt": "2019-08-24T14:15:22Z",
// "updatedAt": "2019-08-24T14:15:22Z",
