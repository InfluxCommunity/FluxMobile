import 'package:flutter/material.dart';
import 'package:flux_mobile/app/dashboard_with_label_example.dart';
import 'package:rapido/rapido.dart';
import 'simple_query_graph_example.dart';

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
      home: ExampleTabs(),
    );
  }
}

class ExampleTabs extends StatefulWidget {
  @override
  _ExampleTabsState createState() => _ExampleTabsState();
}

class _ExampleTabsState extends State<ExampleTabs> {
  DocumentList userDocs;
  String queryString = '''from(bucket: "PlantBuddy")
  |> range(start: -24h)
  |> filter(fn: (r) => r._measurement == "humidity" or r._measurement == "light" or r._measurement == "moisture" or r._measurement == "temp")
  |> filter(fn: (r) => r._field == "soilTemp" or r._field == "soilMoisture" or r._field == "light" or r._field == "humidity" or r._field == "airTemp")''';

  @override
  void initState() {
    super.initState();
    userDocs = DocumentList("InfluxDBUser", labels: {
      "Organization": "org",
      "OrgId": "orgId",
      "Token": "token",
      "Base URL": "url"
    }, onLoadComplete: (DocumentList loadedDoc) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Examples"),
          bottom: TabBar(
            tabs: <Widget>[
              Text("1"),
              Text("2"),
            ],
          ),
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
        body: TabBarView(children: [
          (userDocs.length == 0 || userDocs == null)
              ? Text("Need to log in ...")
              : SimpleQueryGraphExample(
                  url: userDocs[0]["url"],
                  org: userDocs[0]["org"],
                  token: userDocs[0]["token"],
                  queryString: queryString,
                ),
          DashboardWithLabelExample(
            label: "mobile",
            baseUrl: userDocs[0]["url"],
            orgId: userDocs[0]["orgId"],
            token: userDocs[0]["token"],
          )
        ]),
      ),
    );
  }
}
