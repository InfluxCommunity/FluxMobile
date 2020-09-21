import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';
import './dashboard_with_label_example.dart';
import './simple_write_example.dart';
import './simple_query_chart_example.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    _initUser();
    super.initState();
  }

  _initUser() async {
    await this.user.loadFromStorage();
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
    if (user.orgName == null || user.baseURL == null || user.token == null) {
      return null;
    }
    return InfluxDBAPI(
      influxDBUrl: user.baseURL,
      org: user.orgName,
      token: user.token,
    );
  }
}

class InfluxDBUser {
  String token;
  String baseURL;
  String orgName;
  FlutterSecureStorage storage = new FlutterSecureStorage();

  loadFromStorage() async {
    Map<String, String> userMaps = await storage.readAll();

    this.token = userMaps["token"];
    this.baseURL = userMaps["url"];
    this.orgName = userMaps["org"];
  }

  saveToStorage() {
    storage.write(key: "token", value: this.token);
    storage.write(key: "url", value: this.baseURL);
    storage.write(key: "org", value: this.orgName);
  }
}

class InfluxDBUserForm extends StatefulWidget {
  final InfluxDBUser user;

  const InfluxDBUserForm({Key key, this.user}) : super(key: key);

  _InfluxDBUserFormState createState() => _InfluxDBUserFormState();
}

class _InfluxDBUserFormState extends State<InfluxDBUserForm> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController orgController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController tokenController = TextEditingController();

  @override
  void initState() {
    orgController.text = widget.user.orgName;
    urlController.text = widget.user.baseURL;
    tokenController.text = widget.user.token;
    super.initState();
  }

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
                widget.user.saveToStorage();
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
                controller: orgController,
                decoration: (InputDecoration(labelText: "Organization Name")),
                onSaved: (String value) {
                  widget.user.orgName = value;
                },
              ),
              TextFormField(
                controller: urlController,
                decoration: (InputDecoration(labelText: "Url")),
                onSaved: (String value) {
                  widget.user.baseURL = value;
                },
              ),
              TextFormField(
                controller: tokenController,
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
