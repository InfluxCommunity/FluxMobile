import 'package:flutter/widgets.dart';

class InfluxDBNoDataCellWidget extends StatelessWidget {
  final String cellType;

  const InfluxDBNoDataCellWidget({Key key, this.cellType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("The query returned no data"),);
  }
}