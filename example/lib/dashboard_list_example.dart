import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';

class DashboardListExample extends StatefulWidget {
  final InfluxDBAPI api;

  const DashboardListExample({Key key, @required this.api}) : super(key: key);

  @override
  _DashboardListExampleState createState() => _DashboardListExampleState();
}

class _DashboardListExampleState extends State<DashboardListExample> {
  List<InfluxDBDashboard> dashboards;

  @override
  void initState() {
    widget.api.dashboards().then((List<InfluxDBDashboard> boards) {
      setState(() {
        dashboards = boards;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (dashboards == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return ListView.builder(
      itemCount: dashboards.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(dashboards[index].name),
        );
      },
    );
  }
}
