import 'dart:core';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangavocabulometer/screens/Review.dart';
import 'package:mangavocabulometer/screens/ReviewHome.dart';
import 'package:mangavocabulometer/screens/ReviewSetA.dart';
import 'package:mangavocabulometer/utils/App_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mangavocabulometer/utils/strings.dart';

class Flashcard extends StatefulWidget {
  @override
  FlashcardState createState() => FlashcardState();
}

class FlashcardState extends State<Flashcard> {
  late List<String> words;
  late List translate_list;
  List indexList = [];
  late List<TextEditingController> translationController;
  TextEditingController controller = TextEditingController();
  late String _uid;
  bool _called = false;
  bool _isWordsExist = true;
  bool _isParticipants = false;
  Map<String, dynamic> wordsList = new Map();
  late SharedPreferences _sharedPreferences;

  @override
  void initState() {
    super.initState();
    words = [];
  }

  Future<List<dynamic>> _load() async {
    var result = [];
    if (!_called) {
      _sharedPreferences = await SharedPreferences.getInstance();
      _uid = _sharedPreferences.getString('uid')!;
      wordsList = new Map();

      await FirebaseFirestore.instance
          .collection("shozemi_words")
          .doc(_uid)
          .get()
          .then((snap) async {
        if (snap.exists) {
          _isParticipants = true;
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return ReviewHome();
          }));

//for shuffle the list
          var shuffleList = new List.generate(32, (i) => i + 1);
          print(shuffleList);
          shuffleList.shuffle(Random());
          print(shuffleList);

          wordsList = snap.data()!["unknown_words"];
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

/*           print(result);

          translationController = new List.generate(
              result.length, (i) => new TextEditingController());

          for (var i = 0; i < indexList.length; i++) {
            translationController[i].text =
                wordsList["${indexList[i]}"]["translation"];
          } */
        } else {
          await FirebaseFirestore.instance
              .collection(Strings.collectionName)
              .doc(_uid)
              .get()
              .then((snapshot) {
            wordsList = snapshot.data()!["unknown_words"];
            if (snapshot.data()!['unknown_words'] == null) _isWordsExist = false;
          });

          words = wordsList.keys.toList();
          //print(words);

          for (var val in words) {
            if (!wordsList[val]["understand"]) result.add(val);
          }
          print(result);

          for (var i = 0; i < result.length; i++) {}

          translationController = new List.generate(
              result.length, (i) => new TextEditingController());
          for (var i = 0; i < result.length; i++) {
            translationController[i].text = wordsList[result[i]]["translation"];
          }
        }
      });

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
    if (_isParticipants) {
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
          .collection(Strings.collectionName)
          .doc(_uid)
          .update({"unknown_words": wordsList});
    } else {
      wordsList[words[index]]["understand"] = true;
      if (wordsList[words[index]]["rememberd"] == null)
        wordsList[words[index]]["rememberd"] = 0;
      wordsList[words[index]]["rememberd"]++;
      setState(() {
        words.removeAt(index);
        translate_list.removeAt(index);
        translationController.removeAt(index);
      });
      if (words.length == 0) {
        _onTapReload();
      }
      await FirebaseFirestore.instance
          .collection(Strings.collectionName)
          .doc(_uid)
          .update({"unknown_words": wordsList});
    }
  }

  _onTapNo(int index) async {
    if (_isParticipants) {
      wordsList[indexList[index].toString()]["understand"] = false;
      if (wordsList[indexList[index].toString()]["review"] == null)
        wordsList[indexList[index].toString()]["review"] = 0;
      setState(() {
        words.removeAt(index);
        indexList.removeAt(index);
        translate_list.removeAt(index);
        translationController.removeAt(index);
      });
      await FirebaseFirestore.instance
          .collection(Strings.collectionName)
          .doc(_uid)
          .update({"unknown_words": wordsList});
    } else {
      wordsList[words[index]]["understand"] = false;
      if (wordsList[words[index]]["review"] == null)
        wordsList[words[index]]["review"] = 0;
      wordsList[words[index]]["review"]++;
      setState(() {
        words.removeAt(index);
        translate_list.removeAt(index);
        translationController.removeAt(index);
      });
      if (words.length == 0) {
        _onTapReload();
      }
      await FirebaseFirestore.instance
          .collection(Strings.collectionName)
          .doc(_uid)
          .update({"unknown_words": wordsList});
    }
  }

  _onTapReload() async {
/*     String col = _isParticipants ? "exp2020" : "ver1.0.0";
    await FirebaseFirestore.instance
        .collection(col)
        .document(_uid)
        .updateData({"unknown_words": wordsList}); */

    setState(() {
      words = [];
      indexList = [];
      _called = false;
    });
  }

  _showInfo(int index) {
    //print(wordsList["${indexList[index]}"]);
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          String key =
              _isParticipants ? indexList[index].toString() : words[index];
          print(key);
          return AlertDialog(
            title: Text(wordsList[key]["title"]),
            content: Text("episode:${wordsList[key]["episode"]}\n"
                "page:${wordsList[key]["page"]} or ${wordsList[key]["page"] + 1}"),
            actions: <Widget>[
              FlatButton(
                  child: Text('OK'), onPressed: () => Navigator.pop(context)),
              FlatButton(
                  child: Text('review manga'),
                  onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return ReviewScreen(
                            wordsList[key]['title'],
                            wordsList[key]["episode"],
                            wordsList[key]["page"],
                            key);
                      })))
            ],
          );
        });
  }

  _deleteWrongWordDialog(int index) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('誤認識単語の報告'),
            content: Text('[send]:誤認識した単語を報告する\n'
                '[cancel]:キャンセル'),
            actions: <Widget>[
              FlatButton(
                child: Text('cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text('send'),
                onPressed: () => _sendWrongWord(index, context),
              )
            ],
          );
        });
  }

  _sendWrongWord(int index, BuildContext context) async {
    String key = _isParticipants ? indexList[index].toString() : words[index];

    var data = {
      words[index]: {"page": wordsList[key]["page"].toString()}
    };
    await FirebaseFirestore.instance
        .collection("wrong words")
        .doc(wordsList[key]["title"])
        .set({wordsList[key]["episode"].toString(): data}, SetOptions(merge: true));
    Navigator.of(context).pop();
  }

  _translate(String s, int index) async {
    setState(() {
      translate_list[index] = true;
    });
  }

  _reviewAllwords(BuildContext context) async {
    //すべての単語を復習しなおす機能
    String col = _isParticipants ? "shozemi_words" : Strings.collectionName;

    await FirebaseFirestore.instance
        .collection(col)
        .doc(_uid)
        .get()
        .then((value) async {
      wordsList = value.data()!["unknown_words"];
      for (var key in wordsList.keys) {
        wordsList[key]["understand"] = false;
      }
      await FirebaseFirestore.instance
          .collection(col)
          .doc(_uid)
          .update({"unknown_words": wordsList});

      setState(() {
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
        title: Text('Flashcard'),
        actions: <Widget>[
          /* FlatButton(
            child: Text(
              'view all >',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) {
              return new AllWords(true);
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
                    'Not exist unknown_words',
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
                        ? Container(
                            padding: EdgeInsets.all(10.0),
                            child: Center(
                                child: Text(
                              '${words.length} unknown_words',
                              style: TextStyle(fontSize: 20.0),
                            )),
                          )
                        : Container(),
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
                            /*child: Center(
                            child: Text('Tap Reload button', style: AppUtils().textFontSize(25.0),)
                        )*/
                          ),
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
          Column(
            children: <Widget>[
              FlatButton(
                child: Text('review >'),
                color: Colors.white30,
                onPressed:
                    () /* {
                    String key = _isParticipants
                        ? indexList[index].toString()
                        : words[index];

                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return ReviewScreen(
                          wordsList[key]['title'],
                          wordsList[key]["episode"],
                          wordsList[key]["page"],
                          key);
                    }));
                  } */
                        =>
                        _showInfo(index),
              ),
              IconButton(
                icon: Icon(Icons.info),
                onPressed: () => _deleteWrongWordDialog(index),
              )
            ],
          ),
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
        .collection("ver1.0.0")
        .doc(_uid)
        .set({"unknown_words": wordsList}, SetOptions( merge: true));
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
