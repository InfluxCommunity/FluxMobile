import 'dart:math';

import '../api/table.dart';
import '../api/row.dart';
import '../api/dashboard.dart';

class InfluxDBDashboardCellWidgetAxis {
  double minimum;
  double maximum;
  double interval;
  int roundFractionDigits;

  InfluxDBDashboardCellWidgetAxis();

  static InfluxDBDashboardCellWidgetAxis fromCellAxis(
      InfluxDBDashboardCellAxis cellAxis) {
    InfluxDBDashboardCellWidgetAxis axis = InfluxDBDashboardCellWidgetAxis();
    axis.minimum = cellAxis.minimum;
    axis.maximum = cellAxis.maximum;
    axis.initializeValues();
    return axis;
  }

  static InfluxDBDashboardCellWidgetAxis fromCellAxisAndTables(
    InfluxDBDashboardCellAxis cellAxis,
    List<InfluxDBTable> tables,
  ) {
    InfluxDBDashboardCellWidgetAxis axis = InfluxDBDashboardCellWidgetAxis();
    axis.minimum = cellAxis.minimum;
    axis.maximum = cellAxis.maximum;
    tables = tables.where((t) => t.rows.length > 0).toList();
    if (tables.length > 0) {
      if (axis.minimum == null || axis.maximum == null) {
        double min, max;
        for (InfluxDBTable table in tables) {
          for (InfluxDBRow row in table.rows) {
            try {
              double v = double.parse(row.value.toString());
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

  void initializeValues() {
    if (minimum != null && maximum != null) {
      double difference = maximum - minimum;
      double differenceLog10 = log(difference) / ln10;
      interval = difference / 10;
      roundFractionDigits = max(0, (2 - differenceLog10.round()));
    }
  }

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
