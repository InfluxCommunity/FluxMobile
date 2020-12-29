import 'package:flutter/material.dart';
import 'package:flux_mobile/src/api/variables.dart';

class InfluxDBVariablesForm extends StatefulWidget {
  final Function onChanged;
  final InfluxDBVariablesList variables;

  const InfluxDBVariablesForm(
      {Key key, this.onChanged, @required this.variables})
      : super(key: key);

  @override
  _InfluxDBVariablesFormState createState() => _InfluxDBVariablesFormState();
}

class _InfluxDBVariablesFormState extends State<InfluxDBVariablesForm> {
  @override
  initState() {
    super.initState();
    widget.variables.onChanged.add(() {
      setState(() {});
    });
  }

  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.variables.length,
        itemBuilder: (BuildContext context, int index) {
          List<DropdownMenuItem> items = List<DropdownMenuItem>();

          widget.variables[index].args.keys.forEach((String str) {
            items.add(
              DropdownMenuItem(
                child: Text(str),
                value: str,
              ),
            );
          });

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(widget.variables[index].name + " : "),
              DropdownButtonHideUnderline(
                child: DropdownButton(
                  value: widget.variables[index].selectedArgName,
                  items: items,
                  onChanged: (value) {
                    setState(() {
                      widget.variables[index].selectedArgName = value;
                      if (widget.onChanged != null) {
                        widget.onChanged(widget.variables);
                      }
                    });
                  },
                ),
              ),
            ],
          );
        });
  }
}
