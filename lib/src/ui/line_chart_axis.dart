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

  /// Creates an uninitialized instance of [InfluxDBLineChartAxis]
  InfluxDBLineChartAxis();

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
      if (axis.minimum == null || axis.maximum == null) {
        double min, max;
        for (InfluxDBTable table in tables) {
          for (InfluxDBRow row in table.rows) {
            try {
              double v = double.parse(row["_value"].toString());
              if (min == null || min > v) {
                min = v;
              }
              if (max == null || max < v) {
                max = v;
              }
            } catch (e) {
              print("Unable to parse row: " + e.toString());
            }
          }
        }
        if (axis.minimum == null) {
          axis.minimum = min;
        }
        if (axis.maximum == null) {
          axis.maximum = max;
        }
      }
    }
    axis.initializeValues();
    return axis;
  }

  /// Initializes additional values for the axis; if `minimum` and `maximum` are set, the `roundFractionDigits` is also initialized.
  void initializeValues() {
    if (minimum != null && maximum != null) {
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