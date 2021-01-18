import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import '../../influxDB.dart';

class InfluxDBNotificationRule {
  InfluxDBAPI api;
  String name;
  String description;
  bool active;
  String id;
  String every;
  String offset;
  String runbookLink;
  DateTime latestCompleted;
  DateTime createdAt;
  DateTime updatedAt;
  TaskSuccess lastRunSucceeded;
  String errorString;
  List<InfluxDBCheckStatus> recentStatuses = [];
  List<InfluxDBNotification> recentNotifications = [];
  List<dynamic> _tagRules;
  Function onLoadComplete;

  InfluxDBNotificationRule.fromAPI(
      {@required this.api, Map<dynamic, dynamic> apiObj}) {
    setPropertertiesFromAPIObj(apiObj);
  }

  TaskSuccess _getTaskSuccess(Map apiObj) {
    switch (apiObj["lastRunStatus"]) {
      case "failed":
        return TaskSuccess.Failed;
      case "success":
        return TaskSuccess.Succeeded;
      case "canceled":
        return TaskSuccess.Canceled;

      default:
        return null;
    }
  }

  setPropertertiesFromAPIObj(Map<dynamic, dynamic> apiObj) async {
    // set essential properties
    name = apiObj["name"];
    description = apiObj["description"];
    active = apiObj["status"] == "active" ? true : false;
    id = apiObj["id"];
    every = apiObj["every"];
    offset = apiObj["offset"];
    offset = apiObj["runbookLink"];

    // set dates
    latestCompleted = apiObj["latestCompleted"] != null
        ? DateTime.parse(apiObj["latestCompleted"])
        : null;
    createdAt = apiObj["createdAt"] != null
        ? DateTime.parse(apiObj["createdAt"])
        : null;
    updatedAt = apiObj["updatedAt"] != null
        ? DateTime.parse(apiObj["updatedAt"])
        : null;

    // set last success state
    lastRunSucceeded = _getTaskSuccess(apiObj);
    errorString = apiObj["lastRunError"];
    _tagRules = apiObj["tagRules"];
    await Future.wait<void>([
      setRecentNotification(),
      setStatuses(),
    ]);
    if (onLoadComplete != null) onLoadComplete();
  }

  Future<bool> setEnabled({bool enabled}) async {
    Response response = await patch(
      api.getURI("/api/v2/notificationRules/${this.id}"),
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

  setRecentNotification() async {
    String flux = """
from(bucket: "_monitoring") |> range(start: -24h)
|> filter(fn: (r) => r._measurement == "notifications")
|> filter(fn: (r) => r._notification_rule_id == "$id")
|> filter(fn: (r) => r._field == "_message")
    """;
    InfluxDBQuery query = InfluxDBQuery(api: api, queryString: flux);
    List<InfluxDBTable> tables = await query.execute();
    if (tables.length > 0) {
      tables.forEach((InfluxDBTable table) {
        table.rows.forEach((InfluxDBRow row) {
          InfluxDBNotification notification = InfluxDBNotification(
              time: DateTime.parse(row["_time"]),
              message: row["_value"],
              checkName: row["_check_name"],
              level: InfluxDBNotificationLevels[row["_level"]],
              notificationEndPoint: row["_notification_endpoint_name"],
              sent: row["_sent"] == "true",
              type: row["_type"]);
          notification.additionalInfo = _additionalInfo(table: table, row: row);
          recentNotifications.add(notification);
        });
      });
    }
  }

  Map<String, String> _additionalInfo({InfluxDBTable table, InfluxDBRow row}) {
    Map<String, String> additionalInfo = {};
    List<String> tagRuleKeys = _tagRules.map((dynamic rule) {
      return rule["key"].toString();
    }).toList();
    table.keys.forEach((String key) {
      if (!key.startsWith("_") && !tagRuleKeys.contains(key)) {
        additionalInfo[key] = row[key];
      }
    });
    return additionalInfo;
  }

  setStatuses() async {
    String flux = """
from(bucket: "_monitoring") |> range(start: -24h) 
|> filter(fn: (r) => r._measurement == "statuses")
|> filter(fn: (r) => r._field == "_message")""";
    _tagRules.forEach((dynamic tagRule) {
      flux +=
          "\n|> filter(fn: (r) => r[\"${tagRule["key"]}\"] ${tagRule["operator"] == "equal" ? "==" : "!="} \"${tagRule["value"]}\")";
    });
    flux += "|> last()";
    InfluxDBQuery query = InfluxDBQuery(
      api: api,
      queryString: flux,
    );
    List<InfluxDBTable> results = await query.execute();
    results.forEach((InfluxDBTable table) {
      if (table.rows.length > 0) {
        InfluxDBRow row = table.rows[0];

        InfluxDBCheckStatus status = InfluxDBCheckStatus(
          level: InfluxDBNotificationLevels[row["_level"]],
          message: row["_value"],
          time: DateTime.parse(
            row["_time"],
          ),
          type: row["_type"],
          checkName: row["_checkName"],
        );
        status.additionalInfo = _additionalInfo(table: table, row: row);
        recentStatuses.add(status);
      }
    });
  }

  Future refresh() async {
    Response response = await get(
      api.getURI("/api/v2/notificationRules/${this.id}"),
      headers: {
        "Authorization": "Token ${api.token.toString()}",
        "Content-type": "application/json",
      },
    );
    if (response.statusCode != 200) {
      api.handleError(response);
    }
    setPropertertiesFromAPIObj(
      json.decode(response.body),
    );
  }
}

class InfluxDBNotification implements InfluxDBCheckStatus{
  int level;
  DateTime time;
  String message;
  String checkName;
  String notificationEndPoint;
  bool sent;
  String type;
  Map<String, String> additionalInfo;

  InfluxDBNotification(
      {this.level,
      this.time,
      this.message,
      this.checkName,
      this.notificationEndPoint,
      this.sent,
      this.type,
      this.additionalInfo});
}

class InfluxDBCheckStatus {
  int level;
  DateTime time;
  String message;
  String checkName;
  String type;
  Map<String, String> additionalInfo;

  InfluxDBCheckStatus(
      {this.level,
      this.time,
      this.message,
      this.checkName,
      this.type,
      this.additionalInfo});
}

const Map<String, int> InfluxDBNotificationLevels = {
  "ok": 0,
  "info": 1,
  "warn": 2,
  "crit": 3
};

// 1. Query for all checks
// 2. For each notification rule, iterate through it's tag rules, extracting key/value tags
// 3. for each tag rule, iterate through each check, finding ones that match each tag rule, add the check_id to a list
// 4. do a flux query for each check_id to to the _monitoring bucket to find the relevant status's?

// Get last sent notification
// from(bucket: "_monitoring") |> range(start: v.timeRangeStart)
// |> filter(fn: (r) => r._measurement == "notifications")
// |> filter(fn: (r) => r._notification_rule_id == "06e733184f57a000")
// |> filter(fn: (r) => r._field == "_message")
// |> last()

// Get last statuses
// from(bucket: "_monitoring") |> range(start: v.timeRangeStart)
// |> filter(fn: (r) => r._measurement == "statuses")
// |> filter(fn: (r) => r.reads == "deadman")
// |> filter(fn: (r) => r._field == "_message")
// |> last()

// properties returned from the api:
// "latestCompleted": "2019-08-24T14:15:22Z",
// "lastRunStatus": "failed",
// "lastRunError": "string",
// "id": "string",
// "endpointID": "string",
// "orgID": "string",
// "ownerID": "string",
// "createdAt": "2019-08-24T14:15:22Z",
// "updatedAt": "2019-08-24T14:15:22Z",
// "status": "active",
// "name": "string",
// "sleepUntil": "string",
// "every": "string",
// "offset": "string",
// "runbookLink": "string",
// "limitEvery": 0,
// "limit": 0,
// "tagRules": [],
// "description": "string",
// "statusRules": [],
// "labels": [],
// "links": {},
// "type": "slack",
// "channel": "string",
// "messageTemplate": "string"
