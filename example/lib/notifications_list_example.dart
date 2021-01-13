import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';

class NotificationsListExample extends StatefulWidget {
  final InfluxDBAPI api;

  const NotificationsListExample({Key key, @required this.api})
      : super(key: key);

  @override
  _NotificationsListExampleState createState() =>
      _NotificationsListExampleState();
}

class _NotificationsListExampleState extends State<NotificationsListExample> {
  List<InfluxDBNotification> _notifications;

  @override
  void initState() {
    setNotifications();
    super.initState();
  }

  setNotifications() async {
    _notifications = await widget.api.notifications();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _notifications == null
        ? Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
            itemCount: _notifications.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(_notifications[index].name),
                subtitle: Text(_notifications[index].description == null
                    ? "no description"
                    : _notifications[index].description),
              );
            },
          );
  }
}
