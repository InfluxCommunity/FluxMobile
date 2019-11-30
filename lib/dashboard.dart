import 'package:flutter/material.dart';
import 'package:rapido/rapido.dart';
import 'package:http/http.dart';
import 'dart:convert';

class Dashboard extends StatefulWidget {
  final Document userDoc;
  final String id;

  const Dashboard({Key key, this.userDoc, this.id}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    getDashboardData();
  }

  List<dynamic> cellsObj;

  getDashboardData() async {
    String url =
        "https://us-west-2-1.aws.cloud2.influxdata.com/api/v2/dashboards/${widget.id}";
    url += "?orgID=${widget.userDoc["orgId"]}";
    print(url);
    Response response = await get(
      url,
      headers: {
        "Authorization": "Token ${widget.userDoc["token"]}",
        "Content-type": "application/json",
      },
    );
    if (response.statusCode != 200) {
      print("WARNING: ${response.statusCode}: ${response.body}");
      return;
    }

    setState(() {
      cellsObj = json.decode(response.body)["cells"];
      print(cellsObj);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cellsObj == null
          ? Center(
              child: Text("Loading Dashboard ..."),
            )
          : ListView.builder(
              itemCount: cellsObj.length,
              itemBuilder: (context, index) {
                return Text(cellsObj[index]["id"]);
              }),
    );
  }
}
