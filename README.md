# flux_mobile

Flutter SDK for InfluxDB 2.0.

**NOTE**: This library is still in early stages of development and there may be incompatible changes until the library achieves version 1.0.

This library is **UNOFFICIAL** community Open Source software. It is not a project formally supported by InfluxData. 

## Getting Started

This repository contains a library for Dart and Flutter that allows building mobile applications interacting with InfluxDB.

The repository also includes examples that show how to use the said components.

## Examples

### Main example file

The `example/main.dart` file is the starting point of the application. It manages logging in to InfluxDB as well as offers a tabbed view of all the examples in this repository.

### Query example

The `example/simple_query_chart_example.dart` file shows how to use `InfluxDBAPI` and `InfluxDBLineChartWidget` widget to allow running user-specified query and show its results as a line chart.

### Dashboard example

The `example/dashboard_with_label_example.dart` file shows how to use `InfluxDBAPI` and `InfluxDBDashboardCellWidget` widget to list all dashboards, filter the result to only ones with a specific label ("`mobile`" in this case) and render all of their cells in a vertical view.

### Write example

The `example/simple_write_example.dart` shows how to build an `InfluxDBPoint` and write it through the `InlfuxDBAPI` object.

## SDK overview

The SDK is split into multiple parts, which are described below:

### InfluxDB 2.0 API client

The `InfluxDBAPI` class is the main class for all interactions with InfluxDB 2.0. It requires initialization with URL to the InfluxDB instance, organization name and token to use.

For example:

```
InfluxDBAPI api = InfluxDBAPI(
  influxDBUrl: url,
  org: org,
  token: token,
);
```

Optionally, there is a `InfluxDBPersistedAPIArgs` class that automatically saves the necessary data in the device's secure storage, and works in conjunciton with `InfluxDBAPIArgsForm` class to provide a UI for entering and editing the settings.


Next, that instance can be used to run queries or retrieve some of the information - such as:

```
InfluxDBQuery query = InfluxDBQuery(queryString, api: api);
tables = await query.execute();
```

This code runs a Flux query and returns list of tables that contain resulting rows.

`InfluxDBAPI` class also contains logic for retrieving certain InfluxDB objects - such as dashboards:

```
List<InfluxDBDashboard> dashboards = await widget.api.dashboards();
return dashboards.where((d) => d.labels.where((l) => l.name == "mobile").length > 0).toList();
```

The example above retrieves all dashboards and then on the client side limits the result to ones that have a "`mobile`" label.

### UI components built on top of InfluxDB 2.0 APIs

The SDK also includes helper widgets that make it easier to embed InfluxDB functionality in a mobile application.

The `InfluxDBLineChartWidget` allows rendering output from any query as a line chart. The output may include one or more tables.

```
InfluxDBLineChartWidget graph = InfluxDBLineChartWidget(
  tables: await api.query(queryString).execute(),
);
```

The example above will create a line chart from a result of running a Flux query stored in `queryString` variable.

The `InfluxDBDashboardCellWidget` widget takes care of rendering a single dashboard cell as part of a user interface, including retrieving color scheme, axis settings and other information.

```
for (InfluxDBDashboardCell cell in cells) {
  childWidgets.add(
    InfluxDBDashboardCellWidget(
      cell: dashboards
    )
  );
)
```

The above creates an instance of `InfluxDBDashboardCellWidget` for each cell in a list of `cells`, that were previously retrieved from an API.

Supported visualizations for InfluxDBDashboardCellWidget are curently:
 * Markdown
 * Line Graph
 * Single Stat
 * Table

 Dashboards can be easily rendered with the `InfluxDBDashboardCellListView` class.
