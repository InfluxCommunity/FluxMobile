import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';

class SimpleQueryChartExample extends StatefulWidget {
  final InfluxDBAPI api;

  SimpleQueryChartExample({@required this.api});

  @override
  _SimpleQueryChartExampleState createState() =>
      _SimpleQueryChartExampleState();
}

class _SimpleQueryChartExampleState extends State<SimpleQueryChartExample> {
  InfluxDBLineChartWidget graph;
  TextEditingController textEditingController = TextEditingController();
  String errorString;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10.0),
              child: graph == null
                  ? Center(
                      child: (errorString != null
                          ? Text(errorString)
                          : Text(
                              "Enter a query below and click the run button")),
                    )
                  : Container(
                      padding: EdgeInsets.all(10.0),
                      constraints: BoxConstraints(maxHeight: 350.00),
                      child: graph),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(border: Border.all()),
                padding: EdgeInsets.all(5.0),
                child: TextField(
                  controller: textEditingController,
                  maxLines: 10,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.play_arrow),
        onPressed: _executeQuery,
      ),
    );
  }

  // Below is the interesting bit
  // Creates an InfluxDBQueryObject, executes it,
  // and then greates an InfluxDBLineChartWidget
  void _executeQuery() async {
    setState(() {
      errorString = "";
      graph = null;
    });

    List<InfluxDBTable> tables;

    String err = "";

    try {
      InfluxDBQuery query = widget.api.query(textEditingController.text);
      tables = await query.execute();
    } on InfluxDBAPIHTTPError catch (e) {
      err = e.readableMessage();
    }
    
    setState(() {
      if (tables != null) {
        errorString = null;
        graph = InfluxDBLineChartWidget(
          tables: tables,
          xAxis: InfluxDBLineChartAxis(),
          yAxis: InfluxDBLineChartAxis(),
        );
      } else {
        graph = null;
        errorString = err;
      }
    });
  }
}
