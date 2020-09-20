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
  InfluxDBUser user = InfluxDBUser();

  @override
  void initState() {
    super.initState();
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
                        return InfluxDBUserForm(user: this.user);
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

    if (user.orgId == null || user.baseURL == null || user.token == null) {
      return null;
    }
    return InfluxDBAPI(
      influxDBUrl: user.baseURL,
      org: user.orgId,
      token: user.token,
    );
  }
}

class InfluxDBUser {
  String orgId;
  String token;
  String baseURL;
}

class InfluxDBUserForm extends StatefulWidget {
  final InfluxDBUser user;

  const InfluxDBUserForm({Key key, this.user}) : super(key: key);

  _InfluxDBUserFormState createState() => _InfluxDBUserFormState();
}

class _InfluxDBUserFormState extends State<InfluxDBUserForm> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                formKey.currentState.save();
                Navigator.pop(context);
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: (InputDecoration(labelText: "Organization Id")),
                onSaved: (String value) {
                  widget.user.orgId = value;
                },
              ),
              TextFormField(
                decoration: (InputDecoration(labelText: "Url")),
                onSaved: (String value) {
                  widget.user.baseURL = value;
                },
              ),
              TextFormField(
                decoration: (InputDecoration(labelText: "Token")),
                onSaved: (String value) {
                  widget.user.token = value;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
