import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mangavocabulometer/main.dart';
import 'package:mangavocabulometer/screens/HomePage.dart';
import 'package:mangavocabulometer/screens/User_Information.dart';
import 'package:mangavocabulometer/utils/strings.dart';
import 'package:mangavocabulometer/utils/Developer.dart';
import 'package:mangavocabulometer/widget/BottomTabBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mangavocabulometer/utils/App_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final checkValueProvider = StateProvider((ref) => true);

class AuthScreen extends StatefulWidget {
  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String _uid = "";
  bool checkValue = false;
  bool isRegesterd = false;

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getCredential();
  }

  _loginButton(BuildContext context) {
    return ElevatedButton(
      child: const Text('Login'),
      onPressed: () async {
        try {
          await auth
              .signInWithEmailAndPassword(
                  email: email.text, password: password.text)
              .then((result) {
            String? uid = result.user?.uid;
            print("User id is ${uid}");
            context
                .read(sharedPreferencesProvider)
                .setString('uid', uid ??= "");
            _navigator(context);
          });
        } catch (e) {
          AppUtils().buildAlertDialog(context, e.toString());
        }
      },
    );
  }

  _createAccountButton(BuildContext context) {
    return ElevatedButton(
      child: const Text('create new account'),
      onPressed: () async {
        try {
          await auth
              .createUserWithEmailAndPassword(
                  email: email.text, password: password.text)
              .then((result) {
            String? uid = result.user?.uid;
            print("User id is ${uid}");
            context
                .read(sharedPreferencesProvider)
                .setString('uid', uid ??= "");
            _navigator(context);
          });
        } catch (e) {
          AppUtils().buildAlertDialog(context, e.toString());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: _layoutBody(context),
      ),
    );
  }

  Widget _layoutBody(BuildContext context) {
    return new Center(
      child: new Form(
        child: new SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 24.0),
              new TextFormField(
                controller: email,
                decoration: const InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 24.0),
              new TextFormField(
                controller: password,
                decoration: new InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24.0),
              Consumer(builder: (context, watch, child) {
                final isChecked = watch(checkValueProvider);
                return CheckboxListTile(
                  value: isChecked.state,
                  onChanged: (value) {
                    isChecked.state = !isChecked.state;
                  },
                  title: new Text("Remember email and password"),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }),
              new Center(
                child: _loginButton(context),
              ),
              new Center(
                child: _createAccountButton(context),
              )
            ],
          ),
        ),
      ),
    );
  }

  _saveLoginInfo(BuildContext context) {
    context
        .read(sharedPreferencesProvider)
        .setBool("check", context.read(checkValueProvider).state);
    context.read(sharedPreferencesProvider).setString("email", email.text);
    context
        .read(sharedPreferencesProvider)
        .setString("password", password.text);
  }

  getCredential() async {
    //ユーザ情報を起動時に取得、checkValueによって判断
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      bool? checkValue = sharedPreferences.getBool("check");
      if (checkValue != null) {
        if (checkValue) {
          email.text = sharedPreferences.getString("email")!;
          password.text = sharedPreferences.getString("password")!;
        } else {
          email.clear();
          password.clear();
          sharedPreferences.clear();
        }
      } else {
        checkValue = false;
      }
    });
  }

  _navigator(BuildContext context) async {
    //ユーザ情報を保存する
    if (context.read(checkValueProvider).state) {
      _saveLoginInfo(context);
    }
    //すでに登録されているかどうかで遷移先を変更
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? uid = sharedPreferences.getString('uid');
    var userInfo = await FirebaseFirestore.instance
        .collection(Strings.collectionName)
        .doc(uid)
        .get();
    //print("user registerd is : ${userInfo.exists}");
    /* await Firestore.instance
        .collection("unknown_words")
        .document(uid)
        .setData({}); */
    if (userInfo.exists) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        if (_uid == 'FmcWAis1TceFD5g3kG71oAHXvPr2')
          return new DevelopPage();
        else
          return new BottomTabBar();
      } //MaterialPageにしないと遷移できなかった
              ));
    } else {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return UserInformationScreen();
      }));
    }
  }

  _navigateFromRegister(BuildContext context) {
    if (context.read(checkValueProvider).state) {
      _saveLoginInfo(context);
    }
    Navigator.of(context).pushReplacementNamed("/UserInformation");
  }
}
