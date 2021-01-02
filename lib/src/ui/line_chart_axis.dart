import 'dart:math';

import '../api/table.dart';
import '../api/row.dart';
import '../api/dashboard.dart';

/// Definition of an single axis (X or Y) in an [InfluxDBDashboardCellWidget].
class InfluxDBLineChartAxis {
  /// Minimum value to show for this axis. Can be `null`, in which case there is no minimum set and it could not be determined from reading [InfluxDBTable] data.
  double minimum;

  /// Maximum value to show for this axis. Can be `null`, in which case there is no maximum set and it could not be determined from reading [InfluxDBTable] data.
  double maximum;

  /// Interval at which the labels should be shown; if `minimum` and `maximum` are not `null`, this is calculated to show 10 labels.
  double interval;

  /// specifies number of digits to round to for rendering values, rendering values with at most `roundFractionDigits` digits after `.`.
  int roundFractionDigits;

  /// optionally incude tables to pre-calculate y-axis min and max
  List<InfluxDBTable> tables;

  /// Creates an uninitialized instance of [InfluxDBLineChartAxis]
  InfluxDBLineChartAxis({this.tables}) {
    if (tables == null) return;

    Map<String, double> minMax = _minMax(tables);
    minimum = minMax["min"];
    maximum = minMax["max"];

    initializeValues();
  }

  static Map<String, double> _minMax(List<InfluxDBTable> tables) {
    dynamic min;
    dynamic max;
    tables.forEach((InfluxDBTable table) {
      table.rows.forEach((InfluxDBRow row) {
        dynamic val = row["_value"];
        if (val.runtimeType == String) {
          return;
        }
        if (min == null) {
          min = val;
          max = val;
        } else {
          if (val < min) min = val;
          if (val > max) max = val;
        }
      });
    });
    return {"min": min.toDouble(), "max": max.toDouble()};
  }

  /// Creates an instance of [InfluxDBLineChartAxis] by retrieving data from [InfluxDBDashboardCellAxis] object.
  static InfluxDBLineChartAxis fromCellAxis(
      InfluxDBDashboardCellAxis cellAxis) {
    InfluxDBLineChartAxis axis = InfluxDBLineChartAxis();
    axis.minimum = cellAxis.minimum;
    axis.maximum = cellAxis.maximum;
    axis.initializeValues();
    return axis;
  }

  /// Creates an instance of [InfluxDBLineChartAxis] by retrieving data from [InfluxDBDashboardCellAxis] object.
  /// If any non-empty [InfluxDBTable] is included, it also optionally initializes `minimum` and `maximum` using all of the values for all tables.
  static InfluxDBLineChartAxis fromCellAxisAndTables(
    InfluxDBDashboardCellAxis cellAxis,
    List<InfluxDBTable> tables,
  ) {
    InfluxDBLineChartAxis axis = InfluxDBLineChartAxis();

    axis.minimum = cellAxis.minimum;
    axis.maximum = cellAxis.maximum;
    tables = tables.where((t) => t.rows.length > 0).toList();
    if (tables.length > 0) {
      Map<String, double> minMax = _minMax(tables);
      axis.minimum = minMax["min"];
      axis.maximum = minMax["max"];
    }
    axis.initializeValues();
    return axis;
  }

  /// Initializes additional values for the axis; if `minimum` and `maximum` are set, the `roundFractionDigits` is also initialized.
  void initializeValues() {
    // gaurd against min/max not being set and that they may be the same
    if (minimum != null && maximum != null && minimum != maximum) {
      double difference = maximum - minimum;
      double differenceLog10 = log(difference) / ln10;
      interval = difference / 10;
      roundFractionDigits = max(0, (2 - differenceLog10.round()));
    }
  }

  /// Converts a value to string, using `roundFractionDigits` if it was initialized or set explicitly.
  String getValueAsString(double value) {
    if (roundFractionDigits != null) {
      return value
          .toStringAsFixed(roundFractionDigits)
          .replaceFirst(RegExp(r'\.0+$'), '');
    } else {
      return "$value";
    }
  }
}
