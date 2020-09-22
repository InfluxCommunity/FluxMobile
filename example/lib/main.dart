import 'package:flutter/material.dart';
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
  PersistedAPIArgs args = PersistedAPIArgs();

  @override
  void initState() {
    _initUser();
    super.initState();
  }

  _initUser() async {
    await this.args.loadFromStorage();
    setState(() {
      
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
                        return APIArgsForm(args: this.args);
                      }),
                    ),
                  );
                  setState(() {
                    api = getApi();
                  });
                })
          ],
        ),
        body: TabBarView(
          children: [
            ((api != null)
                ? SimpleQueryChartExample(api: api)
                : Center(
                    child: Text("Need to log in ..."),
                  )),
            ((api != null)
                ? DashboardWithLabelExample(label: "mobile", api: api)
                : Center(
                    child: Text("Need to log in ..."),
                  )),
            ((api != null)
                ? SimpleWriteExample(api: api)
                : Center(
                    child: Text("Need to log in ..."),
                  )),
          ],
        ),
      ),
    );
  }

  InfluxDBAPI getApi() {
    if (args.orgName == null || args.baseURL == null || args.token == null) {
      return null;
    }
    return InfluxDBAPI(
      influxDBUrl: args.baseURL,
      org: args.orgName,
      token: args.token,
    );
  }
}

