import 'package:flutter/material.dart';
import 'package:flux_mobile/influxDB.dart';

class VariablesExample extends StatefulWidget {
  final InfluxDBAPI api;

  const VariablesExample({Key key, this.api}) : super(key: key);

  @override
  _VariablesExampleState createState() => _VariablesExampleState();
}

class _VariablesExampleState extends State<VariablesExample> {
  List<InfluxDBVariable> variables;

  @override
  void initState() {
    _getVariables();
    super.initState();
  }

  _getVariables() async {
    variables = await widget.api.variables();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: variables == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.grey,
                    height: 150.0,
                    child: InfluxDBVariablesForm(
                      onChanged: (List<InfluxDBVariable> vars) {
                        setState(() {
                          variables = vars;
                        });
                      },
                      variables: variables,
                    ),
                  ),
                  Container(
                    height: 200.0,
                    child: ListView.builder(
                      itemCount: variables.length,
                      itemBuilder: (BuildContext context, int index) {
                        InfluxDBVariable variable = variables[index];
                        return Text(
                            "${variable.name} : ${variable.selectedArgName}");
                      },
                    ),
                  ),
                ],
              ));
  }
}
