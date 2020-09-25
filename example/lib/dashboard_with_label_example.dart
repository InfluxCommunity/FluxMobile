import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';

class DashboardWithLabelExample extends StatefulWidget {
  final String label;
  final InfluxDBAPI api;

  DashboardWithLabelExample({@required this.api, this.label});

  @override
  _DashboardWithLabelExampleState createState() =>
      _DashboardWithLabelExampleState();
}

class _DashboardWithLabelExampleState extends State<DashboardWithLabelExample> {
  // initialize cards to null to show the progress indicator until response from server is received
  InfluxDBDashboard dashboard;

  @override
  void initState() {
    _setDashboard();
    super.initState();
  }

  _setDashboard() async {
    List<InfluxDBDashboard> dashboards = await widget.api.dashboards(label: widget.label);
    setState(() {
      this.dashboard = dashboards[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this.dashboard == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return InfluxDBDashboardListView(dashboard: this.dashboard);
    }
  }

}
