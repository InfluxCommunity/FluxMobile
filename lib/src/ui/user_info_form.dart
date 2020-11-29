import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passwordfield/passwordfield.dart';

/// Provide persistence for the arguments needed to
/// initialize an instance of InfluxDBAPI, using secrets store
class InfluxDBPersistedAPIArgs {
  String token;
  String baseURL;
  String orgName;
  FlutterSecureStorage storage = new FlutterSecureStorage();

  /// Read the data from secure storage. Fields that are not persisted
  /// will remain null
  loadFromStorage() async {
    Map<String, String> userMaps = await storage.readAll();

    this.token = userMaps["token"];
    this.baseURL = userMaps["url"];
    this.orgName = userMaps["org"];
  }

  /// Write the data to secure storage
  saveToStorage() {
    storage.write(key: "token", value: this.token);
    storage.write(key: "url", value: this.baseURL);
    storage.write(key: "org", value: this.orgName);
  }

  bool get setup {
    return (baseURL != null && orgName != null && token != null);
  }
}

/// A form to allow a user to enter (and persist)
/// information to make API calls work
class InfluxDBAPIArgsForm extends StatefulWidget {
  final InfluxDBPersistedAPIArgs args;

  /// Create an instance of a form using an instance of args
  const InfluxDBAPIArgsForm({Key key, @required this.args}) : super(key: key);

  _InfluxDBAPIArgsFormState createState() => _InfluxDBAPIArgsFormState();
}

class _InfluxDBAPIArgsFormState extends State<InfluxDBAPIArgsForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _orgController = TextEditingController();
  TextEditingController _urlController = TextEditingController();
  TextEditingController _tokenController = TextEditingController();

  @override
  void initState() {
    _orgController.text = widget.args.orgName;
    _urlController.text = widget.args.baseURL;
    _tokenController.text = widget.args.token;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                _formKey.currentState.save();
                widget.args.saveToStorage();
                Navigator.pop(context);
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _orgController,
                decoration: (InputDecoration(labelText: "Organization Name")),
                onSaved: (String value) {
                  widget.args.orgName = value;
                },
              ),
              TextFormField(
                controller: _urlController,
                decoration: (InputDecoration(labelText: "URL")),
                onSaved: (String value) {
                  widget.args.baseURL = value;
                },
              ),
              FormField(
                builder: (FormFieldState<String> state) {
                  return PasswordField(
                    hasFloatingPlaceholder: true,
                    floatingText: "Token",
                    controller: _tokenController,
                    hintText: "Token",
                  );
                },
                onSaved: (String value) {
                  widget.args.token = _tokenController.text;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
