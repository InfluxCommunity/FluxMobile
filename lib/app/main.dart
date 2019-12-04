import 'package:flutter/material.dart';
import 'package:rapido/rapido.dart';
import 'package:flux_mobile/influxDB.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flux Mobile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flux Mobile'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Text loadingPrompt = Text("Running Query ....");
  Text needLoginPrompt = Text("Click the Little Person Icon to Log in");
  String errorMessage = "";
  InfluxDBQuery query;

  DocumentList userDocs;

  InfluxDBChart influxdbChart;
  @override
  void initState() {
    super.initState();
    userDocs = DocumentList(
      "InfluxDBUser",
      labels: {
        "Organization": "org",
        "OrgId": "orgId",
        "Token": "token",
        "Base URL": "url"
      },
      onLoadComplete: ((DocumentList loadedList) {
        print("load complete");
        if (userDocs.length > 0) {
          _executeQuery();
        }
      }),
    );
  }

  void _executeQuery() async {
    Document userDoc = userDocs[0];
    String queryString = '''from(bucket: "PlantBuddy")
  |> range(start: -24h)
  |> filter(fn: (r) => r._measurement == "humidity" or r._measurement == "light" or r._measurement == "moisture" or r._measurement == "temp")
  |> filter(fn: (r) => r._field == "soilTemp" or r._field == "soilMoisture" or r._field == "light" or r._field == "humidity" or r._field == "airTemp")''';
    query = InfluxDBQuery(
        queryString: queryString,
        influxDBUrl: userDoc["url"],
        org: userDoc["org"],
        token: userDoc["token"]);
    List<InfluxDBTable> tables = await query.execute();
    setState(() {
      influxdbChart = InfluxDBChart(
        tables: tables,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: influxdbChart == null
          ? Container(
              child: Center(
                child: userDocs == null || userDocs.length < 1
                    ? Text("You need to log in")
                    : Text("Loading ..."),
              ),
            )
          : Center(child: influxdbChart),
      appBar: AppBar(
        title: Text("Plant Buddy"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.person),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((BuildContext context) {
                      return DocumentForm(userDocs,
                          document: userDocs.length > 0 ? userDocs[0] : null);
                    }),
                  ),
                );
                if (userDocs.length > 0) {}
              })
        ],
      ),
    );
  }
}
