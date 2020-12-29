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
  InfluxDBVariablesList variables;
  @override
  void initState() {
    _setDashboard();
    super.initState();
  }

  _setDashboard() async {
    variables = await widget.api.variables();
    await _resetDashboard();
  }

  Future _resetDashboard() async {
    List<InfluxDBDashboard> dashboards =
        await widget.api.dashboards(label: widget.label, variables: variables);

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
      return Scaffold(
        body: InfluxDBDashboardCellListView(dashboard: this.dashboard),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (_) => new SimpleDialog(
                children: [
                  Container(
                    height: 300.0,
                    child: InfluxDBVariablesForm(
                      variables: variables,
                      onChanged: (List<InfluxDBVariable> vars) {
                        setState(() {
                          variables = vars;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          onPressed: (() {
                            Navigator.pop(context);
                            setState(() {
                              this.dashboard = null;
                              _resetDashboard();
                            });
                          }),
                          child: Text("Ok"),
                        ),
                      ),
                    ],
                  )
                ],
                title: Text("Variables"),
              ),
              barrierDismissible: false,
            );
          },
          child: Icon(Icons.settings),
        ),
      );
    }
  }
}
