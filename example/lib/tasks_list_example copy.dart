import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';

class TasksListExample extends StatefulWidget {
  final InfluxDBAPI api;

  const TasksListExample({Key key, @required this.api}) : super(key: key);

  @override
  _TasksListExampleState createState() => _TasksListExampleState();
}

class _TasksListExampleState extends State<TasksListExample> {
  List<InfluxDBTask> tasks;

  @override
  void initState() {
    widget.api.tasks().then((List<InfluxDBTask> value) {
      setState(() {
        tasks = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (tasks == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(tasks[index].name),
          subtitle: tasks[index].description == null
              ? null
              : Text(tasks[index].description),
          leading: tasks[index].active
              ? Icon(Icons.play_arrow)
              : Icon(Icons.play_disabled),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return TaskScaffold(task: tasks[index]);
            }));
          },
        );
      },
    );
  }
}

class TaskScaffold extends StatefulWidget {
  final InfluxDBTask task;

  const TaskScaffold({Key key, this.task}) : super(key: key);
  @override
  _TaskScaffoldState createState() => _TaskScaffoldState();
}

class _TaskScaffoldState extends State<TaskScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.task.name),
            Text(widget.task.id),
          ],
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            value: widget.task.active,
            onChanged: (bool newValue) {
              widget.task.setEnabled(enabled: newValue).then((bool val) {
                setState(() {});
              });
            },
            title: Text("Enabled"),
          ),
          ListTile(
            title: Text(widget.task.description == null
                ? "No Description"
                : widget.task.description),
          ),
          Container(
            decoration: BoxDecoration(border: Border.all()),
            height: 100.0,
            child: Text(widget.task.queryString),
          ),
          Container(
            decoration: BoxDecoration(border: Border.all()),
            height: 100.0,
            child: Text(widget.task.errorString == null
                ? "No Errors"
                : widget.task.errorString),
          ),
          ListTile(
            title: Text(
              widget.task.latestCompleted == null
                  ? ""
                  : widget.task.latestCompleted.toString(),
            ),
            subtitle: Text(
              "Last Successful Run",
            ),
          ),
          ListTile(
            title: Text(
              widget.task.createdAt == null
                  ? ""
                  : widget.task.createdAt.toString(),
            ),
            subtitle: Text(
              "Creation Date",
            ),
          ),
          ListTile(
            title: Text(
              widget.task.updatedAt == null
                  ? ""
                  : widget.task.updatedAt.toString(),
            ),
            subtitle: Text(
              "Last Updated On",
            ),
          ),
        ],
      ),
    );
  }
}
