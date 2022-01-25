import 'package:flutter/material.dart';
import 'package:mangavocabulometer/screens/AuthTestPage.dart';
import 'package:mangavocabulometer/widget/BottomTabBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestPage extends StatefulWidget {
  String id;
  String day;
  bool isSetA;

  TestPage(this.id, this.day, this.isSetA);
  @override
  State<StatefulWidget> createState() {
    return TestPageState(this.id, this.day, this.isSetA);
  }
}

class TestPageState extends State<StatefulWidget> {
  String id;
  String day;
  bool isSetA;

  TestPageState(this.id, this.day, this.isSetA);

  late bool _loadData;

  List<String> testWord = [];
  late List<TextEditingController> _controllerList;

  @override
  void initState() {
    super.initState();
    _loadData = false;
    _controllerList = new List.generate(8, (i) => new TextEditingController());
  }

  Future<List<String>> _future() async {
    if (!_loadData) {
      List<String> wordList = [];

      await FirebaseFirestore.instance
          .collection("test")
          .doc(id)
          .get()
          .then((snapshot) {
        Map<String, dynamic> tmp = new Map();
        if (isSetA) {
          tmp = snapshot.data()!["setA"][day];
        } else {
          tmp = snapshot.data()!["setB"][day];
        }
        for (var key in tmp.keys) {
          wordList.add(key);
        }
        testWord = [];
        testWord.addAll(wordList);
        print(wordList);
      });
      _loadData = true;
      return wordList;
    } else {
      return testWord;
    }
  }

  _onChanged(String answer, int i) {
    _controllerList[i].text = answer;
    print(answer);
  }

  _uploadAnswer(BuildContext context) async {
    //TODO firebaseアップロード
    print('uploading');

    List<String> answerList = [];
    Map<String, dynamic> data = new Map();

    for (var i = 0; i < testWord.length; i++) {
      data[testWord[i]] = {'ans_user': _controllerList[i].text};
    }

    if (isSetA) {
      await FirebaseFirestore.instance.collection("test").doc(id).set({
        "setA": {day: data}
      }, SetOptions(merge: true));
    } else {
      await FirebaseFirestore.instance.collection("test").doc(id).set({
        "setB": {day: data}
      }, SetOptions(merge: true));
    }

    /* Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return AuthTestPage();
    })); */
    Navigator.of(context).pushReplacementNamed("/HomePage");
  }

  _confirmDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('解答終了の確認'),
            content: Text('解答を終了しますか？'),
            actions: <Widget>[
              FlatButton(
                child: Text('cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              FlatButton(
                child: Text('finish'),
                onPressed: () => _uploadAnswer(context),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Test"),
        actions: <Widget>[
          Container(
            height: 20.0,
            width: 150.0,
            decoration: BoxDecoration(
                color: Colors.green[300],
                border: Border.all(color: Colors.black38),
                borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: Icon(Icons.file_upload),
              title: Text('Tap to finish'),
              onTap: () => _confirmDialog(context),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _future(),
          builder: (BuildContext context, AsyncSnapshot list) {
            if (!list.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: list.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _questionCard(list.data[index], index);
                        }),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _questionCard(String word, int index) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: Text(
                word,
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            SizedBox(
              height: 70.0,
              width: 180.0,
              child: TextField(
                controller: _controllerList[index],
                textAlign: TextAlign.center,
                onSubmitted: (String s) => _onChanged(s, index),
                decoration: const InputDecoration(
                  hintText: '解答を入力してください',
                  border: const UnderlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
