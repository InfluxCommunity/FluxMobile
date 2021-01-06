import 'package:example/dashboard_list_example.dart';
import 'package:example/tasks_list_example%20copy.dart';
import 'package:example/visualizations_example.dart';
import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';
import './dashboard_with_label_example.dart';
import './simple_write_example.dart';
import './simple_query_chart_example.dart';
import 'bucket_list_example.dart';

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
  InfluxDBPersistedAPIArgs args = InfluxDBPersistedAPIArgs();

  @override
  void initState() {
    _initUser();
    super.initState();
  }

  _initUser() async {
    await this.args.loadFromStorage();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    InfluxDBAPI api = getApi();

    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Examples"),
          bottom: TabBar(
            tabs: <Widget>[
              Text("Query"),
              Text("Board"),
              Text("DB List"),
              Text("Viz"),
              Text("Tasks"),
              Text("Buckets"),
              Text("Write"),
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
                        return InfluxDBAPIArgsForm(args: this.args);
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
                ? SimpleQueryChartExample(
                    api: api,
                  )
                : Center(
                    child: Text("Need to log in ..."),
                  )),
            ((api != null)
                ? DashboardWithLabelExample(
                    label: "mobile",
                    api: api,
                  )
                : Center(
                    child: Text("Need to log in ..."),
                  )),
            ((api != null)
                ? DashboardListExample(
                    api: api,
                  )
                : Center(
                    child: Text("Need to log in ..."),
                  )),
            ((api != null)
                ? VisualizationsListView()
                : Center(
                    child: Text("Need to log in ..."),
                  )),
            ((api != null)
                ? TasksListExample(
                    api: api,
                  )
                : Center(
                    child: Text("Need to log in ..."),
                  )),
            ((api != null)
                ? BucketListExample(
                    api: api,
                  )
                : Center(
                    child: Text("Need to log in ..."),
                  )),
            ((api != null)
                ? SimpleWriteExample(
                    api: api,
                  )
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
    return InfluxDBAPI.fromPersistedAPIArgs(args);
  }
}
