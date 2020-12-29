import 'package:flutter/material.dart';
import '../api/dashboard.dart';
import 'dashboard_cell_widget.dart';

class InfluxDBDashboardCellListView extends StatefulWidget {
  final InfluxDBDashboard dashboard;

  const InfluxDBDashboardCellListView({Key key, this.dashboard})
      : super(key: key);

  @override
  _InfluxDBDashboardCellListViewState createState() =>
      _InfluxDBDashboardCellListViewState();
}

class _InfluxDBDashboardCellListViewState
    extends State<InfluxDBDashboardCellListView> {
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
    if (_cellWidgets.length == null || _cellWidgets.length == 0)
      return Center(
        child: CircularProgressIndicator(),
      );

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
