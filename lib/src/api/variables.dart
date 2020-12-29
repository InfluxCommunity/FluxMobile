import 'dart:collection';

import '../../influxDB.dart';

/// Enumeration to track if a query-based variable has completed retrieving it's values
/// by executing its query
enum VariableHyrdationState { UnHydrated, Hydrated }

/// A Variable that containers a query
/// The query may itself contain variables (subVariables)
class InfluxDBQueryVariable implements InfluxDBVariable {
  dynamic _obj;
  final List<InfluxDBQueryVariable> children = [];
  VariableHyrdationState hydrationState = VariableHyrdationState.UnHydrated;
  final List<Function> onHydrated = List<Function>();
  final List<Function> onChanged = List<Function>();
  final VariablesList variables;
  final InfluxDBAPI api;
  final type = "query";
  Map<String, dynamic> args = Map<String, dynamic>();
  String _selectedArgName;
  String name;

  /// The name of the currently selected Argument (or option for the variable).
  @override
  String get selectedArgName => _selectedArgName;

  @override
  set selectedArgName(String selectedArgName) {
    _selectedArgName = selectedArgName;
    onChanged.forEach((element) {
      element();
    });
  }

  /// The query string to execute
  String get query => _obj["arguments"]["values"]["query"];

  /// Construct a query-based platform variable.
  /// This is typically not called directly, but is done using the InfluxDBAPI.variables() function
  InfluxDBQueryVariable({this.name, obj, this.variables, this.api}) {
    this._obj = obj;
  }

  /// A callback when the user has changed the selection of a variable
  /// contained within the query, causing the query to execute wiht the new
  /// variable values
  onSubVariableSlectionChange() async {
    await executeVariableQuery();
  }

  /// A callback for when subvariables are first executed and values populated.
  /// Waits until all sub-queries are complete before executing its own query.
  onSubVariableHydrated() {
    bool childrenHydrated = true;
    children.forEach((element) {
      if (element.hydrationState != VariableHyrdationState.Hydrated)
        childrenHydrated = false;
    });
    if (childrenHydrated) executeVariableQuery();
  }

  /// Execute the query for the variable (along with all currently populated
  /// platform variables) and populate the options for the variable
  executeVariableQuery() {
    InfluxDBQuery q =
        InfluxDBQuery(queryString: this.query, api: api, variables: variables);

    q.execute().then((tables) {
      _populateArgs(tables);
    });
  }

  void _populateArgs(List<InfluxDBTable> tables) {
    args.clear();
    tables.forEach((InfluxDBTable table) {
      table.rows.forEach((InfluxDBRow row) {
        args.addAll({
          row["_value"]: {"type": "StringLiteral", "value": row["_value"]}
        });
      });
    });

    // set the selection to the first item returned
    _selectedArgName = tables[0].rows[0]["_value"];

    // If this is the first time the query has been executed
    // mark this variable as hydrated, add it to the list of variables.
    // Then call all interested parties that you are done so
    // they can hydrate themselves.
    if (hydrationState != VariableHyrdationState.Hydrated) {
      hydrationState = VariableHyrdationState.Hydrated;
      variables.add(
        this,
      );
      onHydrated.forEach((element) {
        element();
      });
    } else {
      // If this is not the first time executing the query, let
      // interated parties (parents) know that your selection has changed
      // so they can update themselves
      onChanged.forEach((element) {
        element();
      });
    }
  }

  /// Get the value for whatever is the selected argument (option).
  /// The selectedValue is a data structure is used when posting queries.
  @override
  Map<String, dynamic> get selectedValue => args[_selectedArgName];

  /// All variables contained in the Variables query
  List<String> get subVariables {
    List<String> subVars = [];
    RegExp exp = RegExp(r'v(\.([\w]+))|(\["(\w)"\])');
    Iterable<RegExpMatch> regExMatches = exp.allMatches(query);
    List<String> subVariableNames = List<String>();

    // if it does have a variable
    // foreach variable in the query, check if it's been hydrated
    regExMatches.forEach((match) {
      subVariableNames.add(query.substring(match.start, match.end));
    });

    // filter out duplicate usages
    subVariableNames = subVariableNames.toSet().toList();

    subVariableNames.forEach((String variableName) {
      String vn = "";
      if (variableName.startsWith("v.")) {
        vn = variableName.substring(2);
      }
      if (variableName.contains("[")) {
        vn = variableName.replaceAll("v[\"", "");
        vn = variableName.replaceAll("\"]", "");
      }
      subVars.add(vn);
    });
    return subVars.toSet().toList();
  }

  @override
  set onChanged(List<Function> _onChanged) {
    onChanged = _onChanged;
  }
}

// A Platform Variable that does not contain a subquery.
// This supports Platform Variables of type csv, Map, as well
// as the timeRange variables
class InfluxDBVariable {
  final String name;
  final Map<String, dynamic> args;
  final String type;
  String selectedArgName;
  List<Function> onChanged = List<Function>();

  // The currently selected value, which is a data structred
  // used in the api.postFluxQuery() funtions
  Map<String, dynamic> get selectedValue {
    return args[selectedArgName];
  }

  // Construct a Variable object. This is typically not done directly
  // but rather via the api.variables() function
  InfluxDBVariable({this.type, this.name, this.args}) {
    if (args.length > 0) selectedArgName = args.keys.elementAt(0);
  }
}

class VariablesList extends ListBase<InfluxDBVariable> {
  List<InfluxDBVariable> _variables = List<InfluxDBVariable>();
  List<Function> onChanged = List<Function>();

  int get length => _variables.length;

  set length(int length) {
    _variables.length = length;
  }

  @override
  operator [](int index) {
    return _variables[index];
  }

  @override
  void operator []=(int index, value) {
    _variables[index] = value;
  }

  @override
  add(InfluxDBVariable element) async {
    _variables.add(element);
    element.onChanged.add(_selectionChanged);
  }

  @override
  void addAll(Iterable<InfluxDBVariable> iterable) {
    iterable.forEach((element) {
      add(element);
    });
  }

  _selectionChanged() {
    onChanged.forEach((Function f) {
      f();
    });
  }
}
