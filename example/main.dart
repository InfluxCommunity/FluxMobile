import 'package:flutter/material.dart';
import 'package:rapido/rapido.dart';

import 'package:flux_mobile/influxDB.dart';

import './dashboard_with_label_example.dart';
import './simple_write_example.dart';
import './simple_query_chart_example.dart';

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

  @override
  void initState() {
    super.initState();
    userDocs = DocumentList("InfluxDBUser",
        labels: {
          "Organization": "org",
          "OrgId": "orgId",
          "Token": "token secret",
          "Base URL": "url"
        },
        persistenceProvider: SecretsPercistence(),
        onLoadComplete: (DocumentList loadedDoc) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    InfluxDBAPI api = getApi();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Examples"),
          bottom: TabBar(
            tabs: <Widget>[Text("Query"), Text("Dashboard"), Text("Write")],
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
        body: TabBarView(
          children: [
            ((api != null)
                ? SimpleQueryChartExample(api: api)
                : Text("Need to log in ...")),
            ((api != null)
                ? DashboardWithLabelExample(label: "mobile", api: api)
                : Text("Need to log in ...")),
            ((api != null)
                ? SimpleWriteExample(api: api)
                : Text("Need to log in ...")),
          ],
        ),
      ),
    );
  }

  InfluxDBAPI getApi() {
    if (userDocs == null || userDocs.length == 0) {
      return null;
    }
    return InfluxDBAPI(
      influxDBUrl: userDocs[0]["url"],
      org: userDocs[0]["org"],
      token: userDocs[0]["token secret"],
    );
  }
}
