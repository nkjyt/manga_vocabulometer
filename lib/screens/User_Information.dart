import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:mangavocabulometer/utils/strings.dart';

class UserInformationScreen extends StatefulWidget {
  @override
  UserInformationScreenState createState() => UserInformationScreenState();
}

class UserInformationScreenState extends State<UserInformationScreen> {
  TextEditingController ageController = new TextEditingController();
  int _testDataNumber = 0;
  int _grade = 3;
  String _gender = '';
  String? _uid = '';
  bool _loading = false;
  bool _isRegesterd = false;
  var _testData = [];
  Map<String, bool> _renderMap = new Map();
  List<String> _renderList = [];

  File? jsonFile;
  late Directory dir;
  String fileName = "input user id";
  bool fileExists = false;
  Map<String, dynamic>? fileContent;

  SharedPreferences? _sharedPreferences;

  @override
  void initState() {
    initializeTestdata();
    getCredential();
    _initializeFileStatus();
  }

  void _onChanged(String? e) => setState(() {
        _gender = e!;
      });

  void _handleCheckList(bool val, String s) {
    setState(() {
      _renderMap[s] = val;
    });
  }

  Future<void> initializeTestdata() async {
    String loadData = await rootBundle.loadString('json/test.json');
    Map<String, dynamic> jsonResponse = json.decode(loadData);
    jsonResponse.forEach((key, value) {
      _testData.add(value);
    });
    for (int i = 0; i < 10; i++) {
      _renderMap[_testData[_testDataNumber][i]['word']] = false;
      _renderList.add(_testData[_testDataNumber][i]['word']);
    }
    setState(() {
      _loading = true;
    });
    //jsonResponse.forEach((key,value) => _data = _data + '$key: $value \x0A');
  }

  _initializeFileStatus() async {
    //jsonファイルに関する初期化

    fileName = _uid! + "-wordlist.json";
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      File jsonFile = new File(directory.path + "/" + fileName);
      bool fileExists = jsonFile.existsSync() ? true : false;
      print('file exists ' + fileExists.toString());
      //if(fileExists) this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
    });
  }

  void _createFile(
      Map<String, dynamic> content, Directory dir, String fileName) {
    print('create file');
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    fileExists = true;
    file.writeAsStringSync(json.encode(content));
  }

  void _writeToFile(Map<String, dynamic> content) async {
    print('write to file');
    if (fileExists) {
      print('file exists');
      Map<String, dynamic> jsonFileContent =
          json.decode(jsonFile!.readAsStringSync());
      jsonFileContent.addAll(content);
      jsonFile!.writeAsStringSync(json.encode(jsonFileContent));
    } else {
      print("File does not exist");
      _createFile(content, dir, fileName);
    }
  }

  getCredential() async {
    //ユーザ情報を起動時に取得、_isRegesterdによって判断
    _sharedPreferences = await SharedPreferences.getInstance();
    _uid = _sharedPreferences!.getString('uid');
    print(_uid);
    var userInfo = await FirebaseFirestore.instance
        .collection(Strings.collectionName)
        .doc(_uid)
        .get();
    print(userInfo.exists);
    if (userInfo.exists) {
      setState(() {
        ageController.text = userInfo.data()?['user']['age'];
        _gender = userInfo.data()?['user']['gender'];
        _isRegesterd = true;
      });
    }
  }

  Future<List<String>> _getTestData() async {
    List<String> _renderList = [];

    for (int i = 0; i < 10; i++) {
      _renderList.add(_testData[0][i]['word']);
    }
    return Future.delayed(new Duration(seconds: 3), () => _renderList);
  }

  _updateTestData() async {
    int countUnknown = 0;
    for (int i = 0; i < _renderList.length; i++) {
      if (_renderMap[_renderList[i]] != null) {
        _renderMap[_renderList[i]]! ? countUnknown++ : null;
      }
    }
    if (countUnknown < 3 && _testDataNumber < 8) {
      //Update test data
      _testDataNumber++;
      _grade++;
      _renderList = [];
      _renderMap = new Map();
      for (int i = 0; i < 10; i++) {
        _renderMap[_testData[_testDataNumber][i]['word']] = false;
        _renderList.add(_testData[_testDataNumber][i]['word']);
      }
      setState(() {});
    } else {
      //finish the test

      _putDatatoFirestore();
    }
  }

  _putDatatoFirestore() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    String? uid = _sharedPreferences?.getString('uid');
    //_sharedPreferences.setBool('Inputed_userInfo', true);
    Map user = {
      //登録するuser情報
      'id': uid,
      'age': ageController.text,
      'gender': _gender,
      'grade': _grade,
    };
    print(user);

    await FirebaseFirestore.instance
        .collection(Strings.collectionName)
        .doc(uid)
        .set({'user': user}, SetOptions(merge: true));
    await FirebaseFirestore.instance
        .collection(Strings.collectionName)
        .doc(uid)
        .set({'unknown_words': {}}, SetOptions(merge: true));

    _sharedPreferences!.setBool('isRegesterd', true);

/*   var userInfo = await FirebaseFirestore.instance.collection("ver1.0.0").doc(uid)
    .get();
   print(userInfo.data['user']);*/
    _setWordlist();

    Navigator.pushReplacementNamed(context, '/HomePage');
  }

  _setWordlist() async {
    String loadData = await rootBundle.loadString('json/wordfreqlist.json');
    Map<String, dynamic> wordfreqlist = jsonDecode(loadData);
    int listLength = wordfreqlist.length;
    var keylist = [];
    print(listLength);
    wordfreqlist.forEach((key, value) => keylist.add(key));
    print(_grade);
    var threshold = (listLength * (_grade - 2) / 8).round();
    print('threshold $threshold');
    var range = (listLength * 0.01).round();
    print(range);

    for (var i = threshold + (range / 2).round();
        i >= threshold - (range / 2).round();
        i--) {
      wordfreqlist[keylist[i]]["understand"] = 0.8;
    }

    var prob1 = 0.81;
    int count1 = 0;
    for (var i = threshold - (range / 2).round(); i >= 0; i--) {
      wordfreqlist[keylist[i]]["understand"] = prob1;
      count1 = count1 + 1;
      if (count1 > range) {
        if (prob1 < 1) {
          prob1 = ((prob1 + 0.01) * 1000).round() / 1000;
        }
        count1 = 0;
      }
    }

    var prob2 = 0.79;
    int count2 = 0;
    for (var i = threshold + (range / 2).round(); i < listLength; i++) {
      wordfreqlist[keylist[i]]["understand"] = prob2;
      count2 = count2 + 1;
      if (count2 > range) {
        if (prob2 > 0) {
          prob2 = ((prob2 - 0.01) * 1000).round() / 1000;
        }
        count2 = 0;
      }
    }

    _writeToFile(wordfreqlist);
    _uploadFileToFireStorage(jsonFile!);
  }

  _uploadFileToFireStorage(File file) async {
    final firebase_storage.Reference ref = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child("wordFreqList/${_uid}-wordlist.json");
    final firebase_storage.UploadTask uploadTask = ref.putFile(file);
    try {
      firebase_storage.TaskSnapshot snapshot = await uploadTask;
    } catch (e) {
      print(uploadTask.snapshot);
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Information"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                    child: Text(
                  'Please tell me yourself',
                  style: TextStyle(fontSize: 25.0),
                )),
                const SizedBox(height: 30.0),
                new TextFormField(
                  controller: ageController,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: 'Age',
                    hintText: 'Input your age',
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(13.0),
                ),
                new RadioListTile(
                  value: 'Male',
                  groupValue: _gender,
                  onChanged: _onChanged,
                  title: Text('Male'),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
                new RadioListTile(
                  value: 'Female',
                  groupValue: _gender,
                  onChanged: _onChanged,
                  title: Text('Female'),
                  activeColor: Colors.pinkAccent,
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
                Divider(),
                _isRegesterd
                    ? Text('')
                    : Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          '意味の分からない単語を選択',
                          style: TextStyle(fontSize: 22.0),
                        )),
                Divider(),
                _isRegesterd
                    ? Text('')
                    : (_loading
                        ? _testDataList()
                        : CircularProgressIndicator()),
                Divider(),
                Center(
                    child: Text(
                  'English level : $_grade',
                  style: TextStyle(fontSize: 25.0),
                )),
                Divider(),
                _isRegesterd
                    ? Text('')
                    : ConstrainedBox(
                        constraints: BoxConstraints.expand(height: 60.0),
                        child: RaisedButton(
                          child: Text("次のページ"),
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          onPressed: () => _updateTestData(),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _testList() {
    return FutureBuilder(
      future: _getTestData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            } else {
              List<String> list = snapshot.data;
              return ListView(
                /* primary: false,
                shrinkWrap: true,*/
                padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                children: list
                    .map((text) => CheckboxListTile(
                          title: Text(text),
                          value: _renderMap[text],
                          onChanged: (val) {
                            _handleCheckList(val!, text);
                          },
                        ))
                    .toList(),
              );
            }
        }
      },
    );
  }

  Widget _testDataList() {
    return ListView(
      primary: false,
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      children: _renderList
          .map((text) => CheckboxListTile(
                title: Text(
                  text,
                  style: TextStyle(fontSize: 18.0),
                ),
                value: _renderMap[text],
                onChanged: (val) {
                  _handleCheckList(val!, text);
                },
              ))
          .toList(),
    );
  }
}
