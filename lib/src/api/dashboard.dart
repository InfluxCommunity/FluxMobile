import 'package:meta/meta.dart';

import 'api.dart';
import 'query.dart';
import 'table.dart';

/// Class that provides information about a dashboard in InfluxDB 2.0.
class InfluxDBDashboard {
  /// Instance of [InfluxDBAPI] that can be used for subsequent API calls.
  final InfluxDBAPI api;

  /// Unique identifier of the dashboard.
  String id;

  /// Dashboard name.
  String name;

  /// Dashboard description.
  String description;

  /// Labels belonging to the dashboard.
  List<InfluxDBDashboardLabel> labels;

  /// List of all cells that are part of this dashboard.
  List<InfluxDBDashboardCellInfo> cellInfos;

  /// Create an instance of [InfluxDBDashboard] from parsed JSON data from API call.
  InfluxDBDashboard.fromAPI({@required this.api, dynamic object}) {
    id = object["id"];
    name = object["name"];
    description = object["description"];
    cellInfos = InfluxDBDashboardCellInfo.fromAPIList(
        dashboard: this, objects: object["cells"]);
    cellInfos.sort((a, b) => a.sortIndex().compareTo(b.sortIndex()));
    labels = InfluxDBDashboardLabel.fromAPIList(objects: object["labels"]);
  }

  /// Retrieves a list of cells in this dashboard. Returns a [Future] of a [List] of [InfluxDBDashboardCell] objects.
  Future<List<InfluxDBDashboardCell>> cells() async {
    List<InfluxDBDashboardCell> result = [];
    // toList() is needed and ensures that all async commands are called before iterating on them
    List<Future<InfluxDBDashboardCell>> futures =
        cellInfos.map((q) => q.cell()).toList();
    for (Future<InfluxDBDashboardCell> future in futures) {
      result.add(await future);
    }
    return result;
  }

  /// Initializes multiple dashboards from parsed JSON data from API call. Returns all items as a list.
  static List<InfluxDBDashboard> fromAPIList(
      {@required InfluxDBAPI api, List<dynamic> objects}) {
    List<InfluxDBDashboard> result = [];
    for (dynamic object in objects) {
      result.add(InfluxDBDashboard.fromAPI(api: api, object: object));
    }
    return result;
  }
}

/// Class that describes a single label for [InfluxDBDashboard].
class InfluxDBDashboardLabel {
  /// Unique id of the label.
  String id;

  /// Label name.
  String name;

  /// Label color as hex with `#` prefix - such as `#ffff00` a yellow color.
  String color;

  /// Label description.
  String description;

  /// Creates an instance of [InfluxDBDashboardLabel] from parsed JSON data from API call.
  InfluxDBDashboardLabel.fromAPI({dynamic object}) {
    id = object["id"];
    name = object["name"];
    if (object["properties"] != null) {
      color = object["properties"]["color"];
      description = object["properties"]["description"];
    }
  }

  /// Initializes multiple instances of [InfluxDBDashboardLabel] from parsed JSON data from API call. Returns all items as a list.
  static List<InfluxDBDashboardLabel> fromAPIList({List<dynamic> objects}) {
    List<InfluxDBDashboardLabel> result = [];
    for (dynamic object in objects) {
      result.add(InfluxDBDashboardLabel.fromAPI(object: object));
    }
    return result;
  }
}

/// Class representing basic information about a single cell in [InfluxDBDashboardLabel]. This information is retrieved along with information on dashboard itself and does not have to be fetched separately.
class InfluxDBDashboardCellInfo {
  /// Dashboard that the cell belongs to.
  final InfluxDBDashboard dashboard;

  /// Instance of [InfluxDBAPI] that can be used for subsequent API calls.
  InfluxDBAPI api;

  /// Unique identifier of the cell.
  String id;

  /// Horizontal position of the cell in the dashboard. A cell is positioned within a dashboard, where horizontal display is split into 12 elements - so `x` must be non-negative and `x + w` has to be 12 or less.
  int x;

  /// Vertical position of the cell in the dashboard. There are no limits on vertical coordinates, aside from the fact that `y` must be non-negative.
  int y;

  /// Width of the cell in the dashboard. A cell is positioned within a dashboard, where horizontal display is split into 12 elements - so `x` must be non-negative and `x + w` has to be 12 or less.
  int w;

  /// Height of the cell in the dashboard. There are no limits on maximum height of a cell.
  int h;

  /// Retrieves detailed information about the specific cell. Returns a [Future] to [InfluxDBDashboardCell].
  Future<InfluxDBDashboardCell> cell() {
    return api.dashboardCell(this);
  }

  /// Creates an instance of [InfluxDBDashboardCellInfo] from parsed JSON data from API call.
  InfluxDBDashboardCellInfo.fromAPI(
      {@required this.dashboard, dynamic object}) {
    api = dashboard.api;
    id = object["id"];
    x = object["x"];
    y = object["y"];
    w = object["w"];
    h = object["h"];
  }

  /// Initializes multiple instances of [InfluxDBDashboardCellInfo] from parsed JSON data from API call. Returns all items as a list.
  static List<InfluxDBDashboardCellInfo> fromAPIList(
      {@required InfluxDBDashboard dashboard, List<dynamic> objects}) {
    List<InfluxDBDashboardCellInfo> result = [];
    for (dynamic object in objects) {
      result.add(InfluxDBDashboardCellInfo.fromAPI(
          dashboard: dashboard, object: object));
    }
    return result;
  }

  /// Returns an index that is helpful for sorting all cells by the order in which they should be displayed and/or rendered.
  int sortIndex() {
    return y * 256 + x;
  }
}

/// Class for describing a single cell in a dashboard, including all of the information that should be shown as well as X and Y axes.
class InfluxDBDashboardCell {
  /// Dashboard that the cell belongs to.
  final InfluxDBDashboard dashboard;

  /// Instance of [InfluxDBAPI] that can be used for subsequent API calls.
  InfluxDBAPI api;

  /// Unique identifier of the cell.
  String id;

  /// Cell name
  String name;

  /// Object describing the X axis of this cell.
  InfluxDBDashboardCellAxis xAxis;

  /// Object describing the Y axis of this cell.
  InfluxDBDashboardCellAxis yAxis;

  /// List of queries that the cell has defined and that should be performed to display its contents.
  List<InfluxDBDashboardCellQuery> queries;

  /// Color scheme that is used by this cell.
  List<dynamic> colors;

  /// Creates an instance of [InfluxDBDashboardCell] from parsed JSON data from API call.
  InfluxDBDashboardCell.fromAPI({@required this.dashboard, dynamic object}) {
    api = dashboard.api;
    id = object["id"];
    name = object["name"];
    dynamic properties = object["properties"];

    colors = properties["colors"];

    xAxis = InfluxDBDashboardCellAxis.fromAPI(
        cell: this, object: properties["axes"]["x"]);
    yAxis = InfluxDBDashboardCellAxis.fromAPI(
        cell: this, object: properties["axes"]["y"]);

    queries = InfluxDBDashboardCellQuery.fromAPIList(
        cell: this, objects: properties["queries"]);
  }

  /// Executes all of the queries for this cell, leveraging parallelism if possible, returning a [List] of [Future] of [InfluxDBTable] objects.
  Future<List<InfluxDBTable>> executeQueries() async {
    List<InfluxDBTable> allTables = [];

    // toList() is needed and ensures that all async commands are called before iterating on them
    List<Future<List<InfluxDBTable>>> futures =
        queries.map((q) => q.query().execute()).toList();
    for (Future<List<InfluxDBTable>> future in futures) {
      allTables.addAll(await future);
    }

    return allTables;
  }
}

/// Definition of an single axis (X or Y) in an [InfluxDBDashboardCell].
class InfluxDBDashboardCellAxis {
  /// Cell that this axis belongs to.
  final InfluxDBDashboardCell cell;

  /// Minimum value to show for this axis. Can be `null`, in which case there is no minimum set.
  double minimum;

  /// Maximum value to show for this axis. Can be `null`, in which case there is no maximum set.
  double maximum;

  /// Create an instance of [InfluxDBDashboardCellAxis] from parsed JSON data from API call.
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

/// Definition of a query in an [InfluxDBDashboardCell].
class InfluxDBDashboardCellQuery {
  /// Cell that this query belongs to.
  final InfluxDBDashboardCell cell;

  /// Instance of [InfluxDBAPI] that can be used for subsequent API calls.
  InfluxDBAPI api;

  /// Name of the query.
  String name;

  /// Query to run, using Flux syntax.
  String queryString;

  /// Creates an instance of [InfluxDBDashboardCellQuery] from parsed JSON data from API call.
  InfluxDBDashboardCellQuery.fromAPI({@required this.cell, dynamic object}) {
    api = cell.api;
    name = object["name"];
    queryString = object["text"];
  }

  /// Initializes multiple instances of [InfluxDBDashboardCellQuery] from parsed JSON data from API call. Returns all items as a list.
  static List<InfluxDBDashboardCellQuery> fromAPIList(
      {@required InfluxDBDashboardCell cell, List<dynamic> objects}) {
    List<InfluxDBDashboardCellQuery> result = [];
    for (dynamic object in objects) {
      result
          .add(InfluxDBDashboardCellQuery.fromAPI(cell: cell, object: object));
    }
    return result;
  }

  InfluxDBQuery query() {
    return api.query(queryString);
  }
}
