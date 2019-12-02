import 'package:flutter/material.dart';
import 'package:rapido/rapido.dart';
import 'package:http/http.dart';
import 'dart:convert';
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
  Text loadingPrompt = Text("Loading Dashboards ...");
  Text needLoginPrompt = Text("Click the Little Person Icon to Log in");

  String errorMessage = "";

  DocumentList dashboardsList = DocumentList(
    "Dasbhoards",
    persistenceProvider: null,
  );

  DocumentList userDocs;
  @override
  void initState() {
    super.initState();
    userDocs = DocumentList(
      "InfluxDBUser",
      labels: {"Organization": "org", "OrgId": "orgId", "Token": "token", "Base URL": "url"},
      onLoadComplete: ((DocumentList loadedList) {
        setState(() {});
        if (userDocs.length > 0) {
          loadDashboardList();
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DocumentListScaffold(
      dashboardsList,
      subtitleKey: "description",
      titleKeys: [
        "name",
      ],
      additionalActions: <Widget>[
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
              if (userDocs.length > 0) {
                loadDashboardList();
              }
            })
      ],
      emptyListWidget: Center(
        child: errorMessage != "" ? Text(errorMessage) : (userDocs.length == 0 ? needLoginPrompt : loadingPrompt),
      ),
      onItemTap: (Document dashboardDoc) {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return Dashboard(userDoc: userDocs[0], id: dashboardDoc["id"]);
        }));
      },
    );
  }

  loadDashboardList() async {
    if (userDocs.length == 0) {
      setState(() {
        dashboardsList.clear();
        errorMessage = "WARNING: Tried to load dashboards when user data was not set.";
      });
      return;
    }

    String url =
        "https://us-west-2-1.aws.cloud2.influxdata.com/api/v2/dashboards";
    url += "?orgID=${userDocs[0]["orgId"]}";
    Response response = await get(
      url,
      headers: {
        "Authorization": "Token ${userDocs[0]["token"]}",
        "Content-type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var returnedObj = json.decode(response.body);
      List<dynamic> dashboardsObj = returnedObj["dashboards"];

      setState(() {
        dashboardsList.clear();
        errorMessage = "";
        dashboardsObj.forEach((dynamic dashboardObj) {
          dashboardsList.add(Document(initialValues: {
            "name": dashboardObj["name"],
            "description": dashboardObj["description"],
            "id": dashboardObj["id"],
          }));
        });
      });
    } else {
      setState(() {
        dashboardsList.clear();
        errorMessage = "Dashboard retrieval error:\n\n${requestError(response)}";
      });
    }
  }

  requestError(Response response) {
    var responseAsJson = {};
    try {
      responseAsJson = json.decode(response.body);
    } catch (e) {
      // response was not JSON
    }

    String info = "";

    if (response.statusCode == 401) {
      info = "invalid credentials";
    } else if (responseAsJson["code"] is String) {
      info = "${responseAsJson["code"]}";
    }

    if (responseAsJson["message"] is String) {
      info += "; details: ${responseAsJson["message"]}";
    }

    return info;
  }
}
