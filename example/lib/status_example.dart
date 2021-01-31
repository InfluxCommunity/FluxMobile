import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';

class StatusExample extends StatefulWidget {
  final InfluxDBAPI api;

  const StatusExample({Key key, @required this.api}) : super(key: key);

  @override
  _StatusExampleState createState() => _StatusExampleState();
}

class _StatusExampleState extends State<StatusExample> {
  List<InfluxDBCheckStatus> _statuses;

  @override
  void initState() {
    widget.api.status(lastOnly: true, timeRangeStart: "-5m").then((value) {
      setState(() {
        _statuses = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _statuses == null
        ? Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
          itemCount: _statuses.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(
                    "${_statuses[index].checkName} : ${_statuses[index].level.toString()}"),
              );
            },
          );
  }
}
