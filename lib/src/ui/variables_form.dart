import 'package:flutter/material.dart';
import 'package:flux_mobile/src/api/variables.dart';

/// A wiget for displaying and allowing users to select
/// [InfluxDBVariable]s defined in their InfluxDB account.
class InfluxDBVariablesForm extends StatefulWidget {
  /// A callback function to track when a user has changed the
  /// selection of a variable in the form.
  final Function onChanged;

  /// The variables being displayed and maintained by the widget.
  final InfluxDBVariablesList variables;

  /// Initialize an instance of this form with the [InfluxDBVariablesList]
  /// to display, and an optional callback to respond to changes.
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

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.variables[index].name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.secondary),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SizedBox(
                      width: 500.0,
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
                  ),
                ),
              ],
            ),
          );
        });
  }
}
