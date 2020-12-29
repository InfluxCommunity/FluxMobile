import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';
import 'package:flux_mobile/src/api/variables.dart';
import 'package:flux_mobile/src/ui/user_info_form.dart';
import 'package:http/http.dart';

import 'dashboard.dart';
import 'error.dart';
import 'point.dart';
import 'query.dart';

/// Root class for interacting with InfluxDB 2.0.
class InfluxDBAPI {
  /// URL to InfluxDB 2.0 API.
  final String influxDBUrl;

  /// Organization name to use for API calls.
  final String org;

  /// Token to use for API calls.
  final String token;

  InfluxDBAPI.fromPersistedAPIArgs(InfluxDBPersistedAPIArgs args)
      : influxDBUrl = args.baseURL,
        org = args.orgName,
        token = args.token;

  InfluxDBAPI(

      /// Initializes InfluxDBAPI object by passing URL, organization and token.
      {@required this.influxDBUrl,
      @required this.org,
      @required this.token});

  /// Runs a query passed as string and returns the [InfluxDBQuery] object
  InfluxDBQuery query(String queryString, {List<InfluxDBVariable> variables}) {
    return InfluxDBQuery(
        api: this, variables: variables, queryString: queryString);
  }

  /// Retrieves raw results of a Flux query using InfluxDB API and returns the output as string
  Future<String> postFluxQuery(String queryString,
      {VariablesList variables}) async {
    Map<String, dynamic> body = Map<String, dynamic>();
    body["query"] = queryString;
    if (variables != null) {
      body["extern"] = Map<String, dynamic>();
      body["extern"]["type"] = "File";
      body["extern"]["package"] = null;
      body["extern"]["imports"] = null;
      body["extern"]["body"] = List<Map<String, dynamic>>();
      Map<String, dynamic> externBodyElement = Map<String, dynamic>();
      externBodyElement["type"] = "OptionStatement";
      externBodyElement["assignment"] = Map<String, dynamic>();
      externBodyElement["assignment"]["type"] = "VariableAssignment";
      externBodyElement["assignment"]
          ["id"] = {"type": "Identifier", "name": "v"};
      externBodyElement["assignment"]["init"] = Map<String, dynamic>();
      externBodyElement["assignment"]["init"]["type"] = "ObjectExpression";

      List<Map<String, dynamic>> formattedVariables =
          List<Map<String, dynamic>>();
      variables.forEach((InfluxDBVariable variable) {
        formattedVariables.add({
          "type": "Property",
          "key": {
            "type": "Identifier",
            "name": variable.name,
          },
          "value": variable.selectedValue,
        });
      });
      externBodyElement["assignment"]["init"]["properties"] =
          formattedVariables;
      body["extern"]["body"].add(externBodyElement);

      body["dialect"] = Map<String, List<String>>();
      body["dialect"] = {
        "annotations": ["group", "datatype", "default"]
      };
    }

    Response response = await post(
      _getURI("/api/v2/query"),
      headers: {
        "Authorization": "Token $token",
        "Accept": "application/csv",
        "Content-type": "application/json",
      },
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      _handleError(response);
    }

    return response.body;
  }

  /// Retrieves a list of dashboards available for current account and returns a [Future] to [List] of [InfluxDBDashboard] objects.
  /// Option label parameter will filter list to dashboards tagged with the supplied lable
  Future<List<InfluxDBDashboard>> dashboards(
      {label: String, VariablesList variables}) async {
    dynamic body = await _getJSONData("/api/v2/dashboards");
    List<InfluxDBDashboard> dashboards = InfluxDBDashboard.fromAPIList(
        api: this, variables: variables, objects: body["dashboards"]);
    if (label != null) {
      dashboards = dashboards
          .where((d) => d.labels.where((l) => l.name == label).length > 0)
          .toList();
    }
    return dashboards;
  }

  /// Retrieves a specific dashboard cell; returns a [Future] to a [InfluxDBDashboardCell] object.
  Future<InfluxDBDashboardCell> dashboardCell(InfluxDBDashboardCellInfo cell,
      {List<InfluxDBVariable> variables}) async {
    dynamic body = await _getJSONData(
        "/api/v2/dashboards/${cell.dashboard.id}/cells/${cell.id}/view");
    return InfluxDBDashboardCell.fromAPI(
        dashboard: cell.dashboard, variables: variables, object: body);
  }

  Future write({@required InfluxDBPoint point, @required String bucket}) async {
    Uri uri = _getURI("/api/v2/write",
        additionalQueryParams: {"bucket": bucket, "precision": "ns"});
    Response response = await post(
      uri,
      headers: {"Authorization": "Token $token"},
      body: point.lineProtocol,
    );
    if (response.statusCode != 204) {
      _handleError(response);
    }
  }

  Uri _getURI(
    urlSuffix, {
    Map<String, String> additionalQueryParams,
  }) {
    Map<String, String> queryParams = {"org": org};
    if (additionalQueryParams != null) {
      queryParams.addAll(additionalQueryParams);
    }

    String url = influxDBUrl;
    if (url.startsWith("https://")) url = url.replaceFirst("https://", "");
    if (url.endsWith("/")) url = url.substring(0, url.length - 1);
    return Uri.https(url, urlSuffix, queryParams);
  }

  /// Parses JSON output or throw appropriate error based on the response
  Future<dynamic> _getJSONData(urlSuffix) async {
    Response response = await get(
      _getURI(urlSuffix),
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
    print("HTTP ERROR: ${response.body}");
    throw InfluxDBAPIHTTPError.fromResponse(response);
  }

  Map<String, dynamic> _timeRangeValue(int magnitude, String unit) {
    return {
      "type": "UnaryExpression",
      "operator": "-",
      "argument": {
        "type": "DurationLiteral",
        "values": [
          {"magnitude": magnitude, "unit": unit}
        ]
      }
    };
  }

  Map<String, dynamic> _windowPeriodValue(
      String name, int magnitude, String unit) {
    return {
      "type": "DurationLiteral",
      "values": [
        {"magnitude": magnitude, "unit": unit}
      ]
    };
  }

  void _addImplicitVariables(VariablesList variables) {
    Map<String, dynamic> startTimeRangeArgs = {
      "Past 5m": _timeRangeValue(5, "m"),
      "Past 15m": _timeRangeValue(15, "m"),
      "Past 1h": _timeRangeValue(1, "h"),
      "Past 6h": _timeRangeValue(6, "h"),
      "Past 12h": _timeRangeValue(12, "h"),
      "Past 24h": _timeRangeValue(24, "h"),
      "Past 2d": _timeRangeValue(2, "d"),
      "Past 7d": _timeRangeValue(7, "d"),
      "Past 30d": _timeRangeValue(30, "d"),
    };
    Map<String, dynamic> stopTimeRangeArgs = Map<String, dynamic>();
    stopTimeRangeArgs["now"] = {
      "type": "CallExpression",
      "callee": {"type": "Identifier", "name": "now"}
    };
    stopTimeRangeArgs.addAll(startTimeRangeArgs);

    Map<String, dynamic> windpwPeriodArgs = {
      "5s": _windowPeriodValue("5s", 5, "s"),
      "15s": _windowPeriodValue("15s", 15, "s"),
      "1m": _windowPeriodValue("1m", 1, "m"),
      "5m": _windowPeriodValue("5m", 5, "m"),
      "15m": _windowPeriodValue("15m", 15, "m"),
      "1h": _windowPeriodValue("1h", 1, "h"),
      "6h": _windowPeriodValue("6h", 6, "h"),
      "12h": _windowPeriodValue("12h", 12, "h"),
      "24h": _windowPeriodValue("24h", 24, "h"),
    };

    InfluxDBVariable timeRangeStart = InfluxDBVariable(
        name: "timeRangeStart", args: startTimeRangeArgs, type: "Identifier");
    InfluxDBVariable timeRangeStop = InfluxDBVariable(
        name: "timeRangeStop", args: stopTimeRangeArgs, type: "Identifier");
    InfluxDBVariable windowPeriod = InfluxDBVariable(
        name: "windowPeriod", args: windpwPeriodArgs, type: "ObjectExpression");
    variables.addAll([timeRangeStart, timeRangeStop, windowPeriod]);
  }

  Future<VariablesList> variables() async {
    VariablesList variables = VariablesList();
    _addImplicitVariables(variables);

    Map<String, dynamic> variablesJson =
        await _getJSONData("/api/v2/variables");
    List<dynamic> vars = variablesJson["variables"];

    vars.forEach((dynamic v) {
      if (v["arguments"]["type"] == "map") {
        Map<String, dynamic> args = Map<String, dynamic>();

        Map<String, dynamic> argVals = v["arguments"]["values"];
        argVals.keys.forEach((String key) {
          args.addAll({
            key: {
              "type": "StringLiteral",
              "value": argVals[key],
            },
          });
        });

        variables.add(
          InfluxDBVariable(
            type: "Identifier",
            args: args,
            name: v["name"],
          ),
        );
      }
      if (v["arguments"]["type"] == "constant") {
        Map<String, dynamic> args = Map<String, dynamic>();

        List<dynamic> argVals = v["arguments"]["values"];
        argVals.forEach((element) {
          args.addAll({
            element: {
              "type": "StringLiteral",
              "value": element,
            },
          });
        });
        variables.add(
          InfluxDBVariable(
            type: "Identifier",
            args: args,
            name: v["name"],
          ),
        );
      }
    });

    Iterable<dynamic> queryVariablesObjs =
        vars.where((element) => element["arguments"]["type"] == "query");

    Map<String, InfluxDBQueryVariable> variableNodeMap =
        Map<String, InfluxDBQueryVariable>();

    // create a map of all of the query variables
    queryVariablesObjs.forEach((varObj) {
      InfluxDBQueryVariable node = InfluxDBQueryVariable(
          name: varObj["name"], obj: varObj, variables: variables, api: this);
      variableNodeMap[varObj["name"]] = node;
    });

    variableNodeMap.forEach((key, value) {
      // find all the child vars in the query
      List<String> subVarNames = value.subVariables;

      // add the children
      subVarNames.forEach((String subVarName) {
        variableNodeMap[key].children.add(variableNodeMap[subVarName]);
        variableNodeMap[subVarName].onHydrated.add(value.onSubVariableHydrated);
        variableNodeMap[subVarName]
            .onChanged
            .add(value.onSubVariableSlectionChange);
      });
    });

    variableNodeMap.forEach((key, value) async {
      if (value.children.length == 0) {
        value.executeVariableQuery();
      }
    });

    return variables;
  }
}
