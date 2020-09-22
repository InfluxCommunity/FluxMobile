import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passwordfield/passwordfield.dart';

class InfluxDBUser {
  String token;
  String baseURL;
  String orgName;
  FlutterSecureStorage storage = new FlutterSecureStorage();

  loadFromStorage() async {
    Map<String, String> userMaps = await storage.readAll();

    this.token = userMaps["token"];
    this.baseURL = userMaps["url"];
    this.orgName = userMaps["org"];
  }

  saveToStorage() {
    storage.write(key: "token", value: this.token);
    storage.write(key: "url", value: this.baseURL);
    storage.write(key: "org", value: this.orgName);
  }
}

class InfluxDBUserForm extends StatefulWidget {
  final InfluxDBUser user;

  const InfluxDBUserForm({Key key, this.user}) : super(key: key);

  _InfluxDBUserFormState createState() => _InfluxDBUserFormState();
}

class _InfluxDBUserFormState extends State<InfluxDBUserForm> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController orgController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController tokenController = TextEditingController();

  @override
  void initState() {
    orgController.text = widget.user.orgName;
    urlController.text = widget.user.baseURL;
    tokenController.text = widget.user.token;
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
                formKey.currentState.save();
                widget.user.saveToStorage();
                Navigator.pop(context);
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: orgController,
                decoration: (InputDecoration(labelText: "Organization Name")),
                onSaved: (String value) {
                  widget.user.orgName = value;
                },
              ),
              TextFormField(
                controller: urlController,
                decoration: (InputDecoration(labelText: "Url")),
                onSaved: (String value) {
                  widget.user.baseURL = value;
                },
              ),
              FormField(
                builder: (FormFieldState<String> state) {
                  return PasswordField(
                    controller: tokenController,
                    hintText: "Token",
                  );
                },
                onSaved: (String value) {
                  widget.user.token = tokenController.text;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
