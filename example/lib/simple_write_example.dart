import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';

class SimpleWriteExample extends StatefulWidget {
  final InfluxDBAPI api;

  SimpleWriteExample({@required this.api});

  @override
  _SimpleWriteExampleState createState() => _SimpleWriteExampleState();
}

class _SimpleWriteExampleState extends State<SimpleWriteExample> {
  InfluxDBLineChartWidget graph;
  TextEditingController textEditingController = TextEditingController();
  String lineProtocol = "";

  TextEditingController bucketController = TextEditingController();
  TextEditingController measureController = TextEditingController();
  TextEditingController timestampController = TextEditingController();
  TextEditingController fieldKey1Controller = TextEditingController();
  TextEditingController fieldValue1Controller = TextEditingController();
  TextEditingController fieldKey2Controller = TextEditingController();
  TextEditingController fieldValue2Controller = TextEditingController();
  TextEditingController tagKey1Controller = TextEditingController();
  TextEditingController tagValue1Controller = TextEditingController();
  TextEditingController tagKey2Controller = TextEditingController();
  TextEditingController tagValue2Controller = TextEditingController();
  bool autoTimestamp = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: "Bucket"),
                  controller: bucketController,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: "Measurement"),
                  controller: measureController,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: "Field Key 1"),
                  controller: fieldKey1Controller,
                ),
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: "Field Value 1"),
                  controller: fieldValue1Controller,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: "Field Key 2"),
                  controller: fieldKey2Controller,
                ),
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: "Field Value 2"),
                  controller: fieldValue2Controller,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: "Tag Key 1"),
                  controller: tagKey1Controller,
                ),
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: "Tag Value 1"),
                  controller: tagValue1Controller,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: "Tag Key 2"),
                  controller: tagKey2Controller,
                ),
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: "Tag Value 2"),
                  controller: tagValue2Controller,
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Checkbox(
                onChanged: (bool value) {
                  setState(() {
                    autoTimestamp = value;
                    if(autoTimestamp == true){
                      timestampController.text = "";
                    }
                  });
                },
                value: autoTimestamp,
              ),
              Text("Auto Timestamp")
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: "Timestamp"),
                  controller: timestampController,
                ),
              ),
            ],
          ),
          RaisedButton(
            child: Text("Send"),
            onPressed: (() {
              Map<String, dynamic> fields = Map<String, dynamic>();
              Map<String, dynamic> tags = Map<String, dynamic>();

              int nanoseconds;
              if (timestampController.text != "" && autoTimestamp == false) {
                nanoseconds = int.parse(timestampController.text);
              }

              if (fieldKey1Controller.text != "" &&
                  fieldValue1Controller.text != "") {
                fields[fieldKey1Controller.text] = fieldValue1Controller.text;
              }
              if (fieldKey2Controller.text != "" &&
                  fieldKey2Controller.text != "") {
                fields[fieldKey2Controller.text] = fieldValue2Controller.text;
              }
              if (tagKey1Controller.text != "" &&
                  tagValue1Controller.text != "") {
                tags[tagKey1Controller.text] = tagValue1Controller.text;
              }
              if (tagKey2Controller.text != "" &&
                  tagKey2Controller.text != "") {
                tags[tagKey2Controller.text] = tagValue2Controller.text;
              }

              if (measureController.text != "" && bucketController.text != "") {
                InfluxDBPoint point = InfluxDBPoint(
                    measurement: measureController.text,
                    fields: fields,
                    tags: tags,
                    nanoseconds: nanoseconds,
                    autoTimestamp: autoTimestamp);
                widget.api.write(point: point, bucket: bucketController.text);

                setState(() {
                  lineProtocol = point.lineProtocol;
                });
              }
            }),
          ),
          Text(lineProtocol),
        ]),
      ),
    );
  }
}
