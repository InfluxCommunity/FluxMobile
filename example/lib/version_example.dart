import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';
import 'package:version/version.dart';

class VersionExample extends StatefulWidget {
  final InfluxDBAPI api;

  const VersionExample({Key key, @required this.api}) : super(key: key);
  @override
  _VersionExampleState createState() => _VersionExampleState();
}

class _VersionExampleState extends State<VersionExample> {
  Version _version;

  @override
  void initState() {
    widget.api.fluxVersion().then((Version v) {
      setState(() {
        _version = v;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_version == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Center(
      child: Text(
        _version.toString(),
      ),
    );
  }
}
