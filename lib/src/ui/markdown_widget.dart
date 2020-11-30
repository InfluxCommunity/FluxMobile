import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class InfluxDBMarkDownWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const InfluxDBMarkDownWidget({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: data[data.keys.first],
      selectable: true,
    );
  }
}
