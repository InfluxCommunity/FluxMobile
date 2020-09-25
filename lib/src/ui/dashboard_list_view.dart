import 'package:flutter/material.dart';
import '../api/dashboard.dart';
import './dashboard_cell_widget.dart';

class InfluxDBDashboardListView extends StatefulWidget {
  final InfluxDBDashboard dashboard;

  const InfluxDBDashboardListView({Key key, this.dashboard}) : super(key: key);

  @override
  _InfluxDBDashboardListViewState createState() =>
      _InfluxDBDashboardListViewState();
}

class _InfluxDBDashboardListViewState extends State<InfluxDBDashboardListView> {
  List<InfluxDBDashboardCellWidget> _cellWidgets;

  @override
  void initState() {
    _loadCells();
    super.initState();
  }

  _loadCells() async {
    _cellWidgets = [];
    List<InfluxDBDashboardCell> cells = await widget.dashboard.cells();
    cells.forEach((InfluxDBDashboardCell cell) {
      _cellWidgets.add(InfluxDBDashboardCellWidget(
        cell: cell,
      ));
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_cellWidgets.length == null) return CircularProgressIndicator();

    return ListView.builder(
      itemCount: _cellWidgets.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: _cellWidgets[index],
        );
      },
    );
  }
}