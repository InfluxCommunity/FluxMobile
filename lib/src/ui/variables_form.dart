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

  final List<String> referencedVariables;

  /// Initialize an instance of this form with the [InfluxDBVariablesList]
  /// to display, and an optional callback to respond to changes.
  const InfluxDBVariablesForm(
      {Key key,
      this.onChanged,
      @required this.variables,
      this.referencedVariables})
      : super(key: key);

  @override
  _InfluxDBVariablesFormState createState() => _InfluxDBVariablesFormState();
}

class _InfluxDBVariablesFormState extends State<InfluxDBVariablesForm> {
  InfluxDBVariablesList _variables;
  @override
  initState() {
    if (widget.referencedVariables == null) {
      _variables = widget.variables;
    } else {
      _variables = InfluxDBVariablesList();
      widget.variables.where(
          (element) => widget.referencedVariables.contains(element.name)).toList().forEach((InfluxDBVariable v) {
            _variables.add(v);
          });
    }
    widget.variables.onChanged.add(() {
      if (this.mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _variables.length,
      itemBuilder: (BuildContext context, int index) {
        List<DropdownMenuItem> items = [];

        _variables[index].args.keys.forEach((String str) {
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
                _variables[index].name,
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
                      value: _variables[index].selectedArgName,
                      items: items,
                      onChanged: (value) {
                        if (this.mounted) {
                          setState(() {
                            _variables[index].selectedArgName = value;
                            if (widget.onChanged != null) {
                              widget.onChanged(_variables);
                            }
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
