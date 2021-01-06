import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flux_mobile/influxDB.dart';

class BucketListExample extends StatefulWidget {
  final InfluxDBAPI api;

  const BucketListExample({Key key, @required this.api}) : super(key: key);

  @override
  _BucketListExampleState createState() => _BucketListExampleState();
}

class _BucketListExampleState extends State<BucketListExample> {
  List<InfluxDBBucket> buckets;

  @override
  void initState() {
    widget.api.buckets().then((List<InfluxDBBucket> value) {
      setState(() {
        buckets = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buckets == null
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: buckets.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(buckets[index].name),
                    ),
                    ListTile(
                      title: Text(buckets[index].description == null
                          ? "no description"
                          : buckets[index].description),
                    ),
                    ListTile(
                      title: Text(buckets[index].retentionSeconds.toString()),
                    ),
                    ListTile(
                      title: Text("Cardinality: ${buckets[index].cardinality}"),
                    ),
                  ],
                ),
              );
            },
          );
  }
}
