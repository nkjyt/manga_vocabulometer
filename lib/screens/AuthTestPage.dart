import 'package:flutter/material.dart';
import 'package:mangavocabulometer/screens/TestPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangavocabulometer/utils/App_utils.dart';

class AuthTestPage extends StatefulWidget {
  @override
  AuthTestPageState createState() => AuthTestPageState();
}

class AuthTestPageState extends State<StatefulWidget> {
  late String _uid;
  List<String> _items = ["1", "2", "4", "8"];
  String _selectedItem = "1";
  var _authList = new Map();

  TextEditingController _password = TextEditingController();
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    _getStoreref();
  }

  _getStoreref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    _uid = sharedPreferences.getString("uid")!;
    var doc = await FirebaseFirestore.instance.collection("test").doc(_uid);

    doc.get().then((data) {
      if (data.exists) {
        _authList = data.data()!["AuthList"];
      } else {
        Map<String, dynamic> authList = {
          "1": {"open": true, "password": 1248, "is_setA": true},
          "2": {"open": true, "password": 2481, "is_setA": true},
          "4": {"open": true, "password": 4812, "is_setA": true},
          "8": {"open": true, "password": 8124, "is_setA": true}
        };
        Map<String, dynamic> tmp = {
          "1": {},
          "2": {},
          "4": {},
          "8": {},
        };
        _authList = authList;
        doc.set({"AuthList": authList}, SetOptions( merge: true));
        doc.set({"setA": tmp, "setB": tmp}, SetOptions(merge: true));
      }
    });
  }

  _onPressed(BuildContext context) {
    if (_authList[_selectedItem]["open"]) {
      print(_authList[_selectedItem]["password"]);
      if (_authList[_selectedItem]["password"].toString() == _password.text) {
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (context) {
          return TestPage(
              _uid, _selectedItem, _authList[_selectedItem]["is_setA"]);
        }));
      } else {
        AppUtils().buildAlertDialog(context, "Invalid Password");
      }
    } else {
      AppUtils().buildNotOpenedDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton<String>(
                value: _selectedItem,
                isExpanded: true,
                onChanged: (newValue) {
                  setState(() {
                    _selectedItem = newValue!;
                  });
                },
                selectedItemBuilder: (context) {
                  return _items.map((String item) {
                    return Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Day $item",
                      ),
                    );
                  }).toList();
                },
                items: _items.map((String item) {
                  return DropdownMenuItem(
                      value: item, child: Text("Day $item"));
                }).toList(),
              ),
              Container(
                padding: EdgeInsets.all(20.0),
              ),
              new TextFormField(
                controller: _password,
                decoration: new InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              Container(
                padding: EdgeInsets.all(20.0),
              ),
              RaisedButton(
                child: Text('Start'),
                color: Theme.of(context).primaryColor,
                onPressed: () => _onPressed(context),
              )
            ],
          ),
        ),
      ),
    );
  }
}
