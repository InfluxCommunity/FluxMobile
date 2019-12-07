import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';

class SimpleQueryGraphExample extends StatefulWidget {
  final String url;
  final String org;
  final String token;
  final String queryString;

  SimpleQueryGraphExample({this.url, this.org, this.token, this.queryString});

  @override
  _SimpleQueryGraphExampleState createState() =>
      _SimpleQueryGraphExampleState();
}

class _SimpleQueryGraphExampleState extends State<SimpleQueryGraphExample> {
  InfluxDBLineGraph graph;
  @override
  void initState() {
    super.initState();
    _executeQuery();
  }

  @override
  Widget build(BuildContext context) {
    if (graph == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: Text("Displays a graph with the given Flux query"),
          ),
        ),
        Container(
            padding: EdgeInsets.all(10.0),
            constraints: BoxConstraints(maxHeight: 350.00),
            child: graph),
      ],
    );
  }

  // Below is the interesting bit
  // Creates an InfluxDBQueryObject, executes it,
  // and then greates an InfluxDBLineGraph
  void _executeQuery() async {
    InfluxDBQuery query = InfluxDBQuery(
        queryString: widget.queryString,
        influxDBUrl: widget.url,
        org: widget.org,
        token: widget.token);
    List<InfluxDBTable> tables = await query.execute();
    graph = InfluxDBLineGraph(
      tables: tables,
    );
    setState(() {
      
    });
  }
}
