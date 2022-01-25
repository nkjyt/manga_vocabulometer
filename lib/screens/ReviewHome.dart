import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mangavocabulometer/screens/ReviewSetA.dart';

class ReviewHome extends StatefulWidget {
  @override
  ReviewHomeState createState() => ReviewHomeState();
}

class ReviewHomeState extends State<ReviewHome> {
  late SharedPreferences _sharedPreferences;

  Future<int> _getRemainWord() async {
    var remainWord = 0;
    _sharedPreferences = await SharedPreferences.getInstance();
    var uid = _sharedPreferences.getString('uid');

    await FirebaseFirestore.instance
        .collection("shozemi_words")
        .doc(uid)
        .get()
        .then((val) {
      Map<String, dynamic> wordsList = val.data()!["unknown_words"];
      for (var key in wordsList.keys) {
        if (!wordsList[key]["understand"]) {
          remainWord++;
        }
      }
    });
    return remainWord;
  }

  _reviewAllwords(BuildContext context) async {
    //すべての単語を復習しなおす機能

    _sharedPreferences = await SharedPreferences.getInstance();
    var uid = _sharedPreferences.getString('uid');

    await FirebaseFirestore.instance
        .collection("shozemi_words")
        .doc(uid)
        .get()
        .then((value) async {
      Map<String, dynamic> wordsList = value.data()!["unknown_words"];
      for (var key in wordsList.keys) {
        wordsList[key]["understand"] = false;
      }
      await FirebaseFirestore.instance
          .collection("shozemi_words")
          .doc(uid)
          .update({"unknown_words": wordsList});
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Review word set A'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FutureBuilder(
                future: _getRemainWord(),
                builder: (BuildContext context, index) {
                  if (!index.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Center(
                      child: Text(
                        "${index.data} words remain",
                        style: TextStyle(fontSize: 24.0),
                      ),
                    );
                  }
                },
              ),
              SizedBox(
                width: 240,
                height: 160,
                child: RaisedButton(
                    child: Text(
                      '復習を始める',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    color: Theme.of(context).primaryColorLight,
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return ReviewSetA();
                        }))),
              ),
              Column(
                children: [
                  Text("すべての単語が再度表示されるようになります",
                      style: TextStyle(fontSize: 16.0)),
                  Container(
                    padding: EdgeInsets.all(8.0),
                  ),
                  SizedBox(
                    height: 80,
                    width: 160,
                    child: RaisedButton(
                        child: Text('再学習', style: TextStyle(fontSize: 20.0)),
                        onPressed: () => _confirmationDialog(context)),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        return true;
      },
    );
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
