import 'dart:core';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangavocabulometer/screens/AllWords.dart';
import 'package:mangavocabulometer/utils/App_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class FlashcardB extends StatefulWidget {
  @override
  FlashcardBState createState() => FlashcardBState();
}

class FlashcardBState extends State<FlashcardB> {
  List<String> words = [];
  List translate_list = [];
  List indexList = [];
  late List<TextEditingController> translationController;
  TextEditingController controller = TextEditingController();
  late String _uid;
  bool _called = false;
  bool _isWordsExist = true;
  Map<String, dynamic> wordsList = new Map();
  late SharedPreferences _sharedPreferences;

  @override
  void initState() {
    super.initState();
  }

  Future<List<dynamic>> _load() async {
    var result = [];

    if (!_called) {
      _sharedPreferences = await SharedPreferences.getInstance();
      _uid = _sharedPreferences.getString('uid')!;
      wordsList = new Map();
      indexList = [];
      List<int> shuffleList = [];

      await FirebaseFirestore.instance
          .collection("shozemi_words")
          .doc(_uid)
          .get()
          .then((snapshot) {
        wordsList = snapshot.data()!["wordsetB"];
        if (snapshot.data()!['wordsetB'] == null)
          _isWordsExist = false;
        else {
          int wordLength = 0;
          wordsList.forEach((key, value) {
            if (!wordsList[key]['understand']) shuffleList.add(int.parse(key));
          });
          //for shuffle the list
          print(shuffleList);
          shuffleList.shuffle(Random());
          print(shuffleList);
          translationController = new List.generate(
              shuffleList.length, (i) => new TextEditingController());

          for (var i = 0; i < shuffleList.length; i++) {
            if (!wordsList['${shuffleList[i]}']["understand"]) {
              result.add(wordsList['${shuffleList[i]}']['word']);
              indexList.add("${shuffleList[i]}");
              translationController[i].text =
                  wordsList['${shuffleList[i]}']["translation"];
            }
          }
        }
      });

      //print(result);

/*       for (var i = 0; i < indexList.length; i++) {
        translationController[i].text =
            wordsList["${indexList[i]}"]["translation"];
        print(translationController[i].text);
      } */

      words = [];
      result.forEach((val) => words.add(val));

      translate_list = new List.generate(words.length, (i) => false);
      _called = true;
      return result;
    } else {
      return words;
    }
  }

  _onTapOK(int index) async {
    wordsList[indexList[index].toString()]["understand"] = true;
    if (wordsList[indexList[index].toString()]["rememberd"] == null)
      wordsList[indexList[index].toString()]["rememberd"] = 0;
    wordsList[indexList[index].toString()]["rememberd"]++;
    setState(() {
      words.removeAt(index);
      indexList.removeAt(index);
      translate_list.removeAt(index);
      translationController.removeAt(index);
    });
    await FirebaseFirestore.instance
        .collection("shozemi_words")
        .doc(_uid)
        .update({"wordsetB": wordsList});
    if (words.length == 0) {
      _onTapReload();
    }
  }

  _onTapNo(int index) async {
    wordsList[indexList[index].toString()]["understand"] = false;
    if (wordsList[indexList[index].toString()]["review"] == null)
      wordsList[indexList[index].toString()]["review"] = 0;
    wordsList[indexList[index].toString()]["review"]++;
    setState(() {
      words.removeAt(index);
      indexList.removeAt(index);
      translate_list.removeAt(index);
      translationController.removeAt(index);
    });
    await FirebaseFirestore.instance
        .collection("shozemi_words")
        .doc(_uid)
        .update({"wordsetB": wordsList});
    if (words.length == 0) {
      _onTapReload();
    }
  }

  _onTapReload() async {
/*     await FirebaseFirestore.instance
        .collection("shozemi_words")
        .doc(_uid)
        .updateData({"wordsetB": wordsList}); */

    setState(() {
      words = [];
      translate_list = [];
      indexList = [];
      _called = false;
    });
  }

  _translate(String s, int index) async {
    setState(() {
      translate_list[index] = true;
    });
  }

  _reviewAllwords(BuildContext context) async {
    //すべての単語を復習しなおす機能
    await FirebaseFirestore.instance
        .collection("shozemi_words")
        .doc(_uid)
        .get()
        .then((value) async {
      wordsList = value.data()!["wordsetB"];
      for (var key in wordsList.keys) {
        wordsList[key]["understand"] = false;
      }
      await FirebaseFirestore.instance
          .collection("shozemi_words")
          .doc(_uid)
          .update({"wordsetB": wordsList});

      setState(() {
        indexList = [];
        words = [];
        translate_list = [];
        _called = false;
      });
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Wordset B'),
        actions: <Widget>[
          /* FlatButton(
            child: Text(
              'view all >',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) {
              return new AllWords(false);
            })),
          ), */
          IconButton(
            icon: Icon(Icons.autorenew),
            onPressed: () => _confirmationDialog(context),
          )
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _load(),
          builder: (BuildContext context, data) {
            if (!data.hasData) {
              if (!_isWordsExist)
                return Center(
                  child: Text(
                    'Not exist unknown words',
                    style: TextStyle(fontSize: 25.0),
                  ),
                );
              else
                return Center(child: CircularProgressIndicator());
            } else {
              //words = data.data.keys.toList();
              return SingleChildScrollView(
                //padding: EdgeInsets.only(bottom: 50.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    (words.length > 0)
                        ? ListView.builder(
                            itemCount: words.length,
                            shrinkWrap: true,
                            primary: false,
                            itemBuilder: (BuildContext context, index) {
                              return _flachCard(context, index);
                            })
                        : Container(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                                child: Text(
                              'Tap Reload button',
                              style: AppUtils().textFontSize(25.0),
                            ))),
                    ConstrainedBox(
                      constraints: BoxConstraints.expand(height: 80.0),
                      child: RaisedButton(
                        child: Text(
                          "Tap to Reload",
                          style: AppUtils().textFontSize(25.0),
                        ),
                        onPressed: () => _onTapReload(),
                      ),
                    )
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _flachCard(BuildContext context, int index) {
    return Card(
      child: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          /*Column(
            children: <Widget>[
              FlatButton(
                child: Text('review >'),
                color: Colors.white30,
                onPressed: () => _showInfo(index),
              ),
              IconButton(
                icon: Icon(Icons.info),
                onPressed: () => _deleteWrongWordDialog(index),
              )
            ],
          ),*/

          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    words[index],
                    style: TextStyle(fontSize: 30.0),
                  ),
                ),
              ),
              Center(
                  child: translate_list[index]
                      ? _translatorTile(index)
                      : _translateButton(index)),
              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    child: Text("No"),
                    color: Colors.red,
                    onPressed: () => _onTapNo(index),
                  ),
                  RaisedButton(
                    child: Text("OK"),
                    color: Colors.green,
                    onPressed: () => _onTapOK(index),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _translateButton(int index) {
    return RaisedButton(
      child: Text("translate"),
      color: Theme.of(context).primaryColorLight,
      onPressed: () => _translate(words[index].toString(), index),
    );
  }

  Widget _translatorTile(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 48.0,
          width: 200.0,
          child: TextField(
            controller: translationController[index],
            textAlign: TextAlign.center,
            onSubmitted: (String s) => _onchanged(s, index),
            decoration: const InputDecoration(
              border: const UnderlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.input),
          onPressed: () {},
        )
      ],
    );
  }

  _onchanged(String s, int index) async {
    wordsList[words[index]]["translation"] = s;
    await FirebaseFirestore.instance
        .collection("shozemi_words")
        .doc(_uid)
        .set({"wordsetB": wordsList}, SetOptions( merge: true));
  }

  _confirmationDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("単語の再復習"),
            content: Text("すべての単語をリストに再表示させますか？"),
            actions: [
              FlatButton(
                child: Text('Yes'),
                onPressed: () => _reviewAllwords(context),
              ),
              FlatButton(
                child: Text('No'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }
}
