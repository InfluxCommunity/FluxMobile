import 'package:meta/meta.dart';

import 'api.dart';
import 'query.dart';
import 'table.dart';

class InfluxDBDashboard {
  final InfluxDBAPI api;
  String id;
  String name;
  String description;
  List<InfluxDBDashboardLabel> labels;
  List<InfluxDBDashboardCellInfo> cellInfos;

  InfluxDBDashboard.fromAPI({@required this.api, dynamic object}) {
    id = object["id"];
    name = object["name"];
    description = object["description"];
    cellInfos = InfluxDBDashboardCellInfo.fromAPIList(dashboard: this, objects: object["cells"]);
    cellInfos.sort((a, b) => a.sortIndex().compareTo(b.sortIndex()));
    labels = InfluxDBDashboardLabel.fromAPIList(objects: object["labels"]);
  }

  Future<List<InfluxDBDashboardCell>> cells() async {
    List<InfluxDBDashboardCell> result = [];
    // toList() is needed and ensures that all async commands are called before iterating on them
    List<Future<InfluxDBDashboardCell>> futures = cellInfos.map((q) => q.cell()).toList();
    for (Future<InfluxDBDashboardCell> future in futures) {
      result.add(await future);
    }
    return result;
  }

  static List<InfluxDBDashboard> fromAPIList({@required InfluxDBAPI api, List<dynamic> objects}) {
    List<InfluxDBDashboard> result = [];
    for (dynamic object in objects) {
      result.add(InfluxDBDashboard.fromAPI(api: api, object: object));
    }
    return result;
  }
}

class InfluxDBDashboardLabel {
  String id;
  String name;
  String color;
  String description;

  InfluxDBDashboardLabel.fromAPI({dynamic object}) {
    id = object["id"];
    name = object["name"];
    if (object["properties"] != null) {
      color = object["properties"]["color"];
      description = object["properties"]["description"];
    }
  }

  static List<InfluxDBDashboardLabel> fromAPIList({List<dynamic> objects}) {
    List<InfluxDBDashboardLabel> result = [];
    for (dynamic object in objects) {
      result.add(InfluxDBDashboardLabel.fromAPI(object: object));
    }
    return result;
  }
}

class InfluxDBDashboardCellInfo {
  final InfluxDBDashboard dashboard;
  InfluxDBAPI api;
  String id;
  int x, y, w, h;

  Future<InfluxDBDashboardCell> cell() {
    return api.dashboardCell(this);
  }

  InfluxDBDashboardCellInfo.fromAPI({@required this.dashboard, dynamic object}) {
    api = dashboard.api;
    id = object["id"];
    x = object["x"];
    y = object["y"];
    w = object["w"];
    h = object["h"];
  }

  static List<InfluxDBDashboardCellInfo> fromAPIList({@required InfluxDBDashboard dashboard, List<dynamic> objects}) {
    List<InfluxDBDashboardCellInfo> result = [];
    for (dynamic object in objects) {
      result.add(InfluxDBDashboardCellInfo.fromAPI(dashboard: dashboard, object: object));
    }
    return result;
  }

  int sortIndex() {
    return y * 256 + x;
  }
}

class InfluxDBDashboardCellAxis {
  final InfluxDBDashboardCell cell;
  double minimum;
  double maximum;
  InfluxDBDashboardCellAxis.fromAPI({@required this.cell, dynamic object}) {
    if (object != null && object.length >= 2) {
      try {
        minimum = double.parse(object["bounds"][0].toString());
      } catch (_) {
        // ignore errors
      }
      try {
        maximum = double.parse(object["bounds"][1].toString());
      } catch (_) {
        // ignore errors
      }
    }
  }
}

class InfluxDBDashboardCellQuery {
  final InfluxDBDashboardCell cell;
  InfluxDBAPI api;
  String name;
  String queryString;

  InfluxDBDashboardCellQuery.fromAPI({@required this.cell, dynamic object}) {
    api = cell.api;
    name = object["name"];
    queryString = object["text"];
  }

  static List<InfluxDBDashboardCellQuery> fromAPIList({@required InfluxDBDashboardCell cell, List<dynamic> objects}) {
    List<InfluxDBDashboardCellQuery> result = [];
    for (dynamic object in objects) {
      result.add(InfluxDBDashboardCellQuery.fromAPI(cell: cell, object: object));
    }
    return result;
  }

  InfluxDBQuery query() {
    return api.query(queryString);
  }
}

class InfluxDBDashboardCell {
  final InfluxDBDashboard dashboard;
  InfluxDBAPI api;
  String id;
  String name;

  InfluxDBDashboardCellAxis xAxis;
  InfluxDBDashboardCellAxis yAxis;

  List<InfluxDBDashboardCellQuery> queries;
  List<dynamic> colors;

  InfluxDBDashboardCell.fromAPI({@required this.dashboard, dynamic object}) {
    api = dashboard.api;
    id = object["id"];
    name = object["name"];
    dynamic properties = object["properties"];

    colors = properties["colors"];

    xAxis = InfluxDBDashboardCellAxis.fromAPI(cell: this, object: properties["axes"]["x"]);
    yAxis = InfluxDBDashboardCellAxis.fromAPI(cell: this, object: properties["axes"]["y"]);

    queries = InfluxDBDashboardCellQuery.fromAPIList(cell: this, objects: properties["queries"]);
  }

  Future<List<InfluxDBTable>> executeQueries() async {
    List<InfluxDBTable> allTables = [];

    // toList() is needed and ensures that all async commands are called before iterating on them
    List<Future<List<InfluxDBTable>>> futures = queries.map((q) => q.query().execute()).toList();
    for (Future<List<InfluxDBTable>> future in futures) {
      allTables.addAll(await future);
    }

    return allTables;
  }
}
