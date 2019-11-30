import 'package:flutter/material.dart';
import 'package:rapido/rapido.dart';

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

  DocumentList dashboardsList =
      DocumentList("Dasbhoards", persistenceProvider: null);

  DocumentList userDocs;
  @override
  void initState() {
    super.initState();
    userDocs = DocumentList(
      "InfluxDBUser",
      labels: {"Organization": "org", "OrgId": " orgId", "Token": "token"},
      onLoadComplete: ((DocumentList loadedList) {
        setState(() {});
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DocumentListScaffold(
      dashboardsList,
      additionalActions: <Widget>[
        IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: ((BuildContext context) {
                  return DocumentForm(userDocs,
                      document: userDocs.length > 0 ? userDocs[0] : null);
                }),
              ));
            })
      ],
      emptyListWidget: Center(
        child: userDocs.length == 0 ? needLoginPrompt : loadingPrompt,
      ),
    );
  }
}
