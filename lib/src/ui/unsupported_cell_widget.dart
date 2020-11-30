import 'package:flutter/widgets.dart';

class InfluxDBUnsupportedCellWidget extends StatelessWidget {
  final String cellType;

  const InfluxDBUnsupportedCellWidget({Key key, this.cellType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Dashboard cells of type \"$cellType\" are not yet supported"),);
  }

}