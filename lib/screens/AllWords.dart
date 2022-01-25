import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangavocabulometer/utils/App_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

class AllWords extends StatefulWidget {
  bool _setIsA;

  AllWords(this._setIsA);

  @override
  State<StatefulWidget> createState() {
    return AllWordsState(this._setIsA);
  }
}

class AllWordsState extends State<StatefulWidget> {
  bool _setIsA;
  late bool _loaded;
  late String uid;
  Map<String, dynamic> wordlist = new Map();
  late List<String> transWords;
  late List<String> tmpList;

  late SharedPreferences _sharedPreferences;

  AllWordsState(this._setIsA);

  @override
  void initState() {
    super.initState();
    _loaded = false;
    transWords = [];
    tmpList = [];
  }

  Future<List<String>> _load() async {
    if (!_loaded) {
      _sharedPreferences = await SharedPreferences.getInstance();
      uid = _sharedPreferences.getString('uid')!;
      List<String> words = [];
      transWords = [];
      tmpList = [];

      await FirebaseFirestore.instance
          .collection('ver1.0.0')
          .doc(uid)
          .get()
          .then((data) {
        if (_setIsA)
          wordlist = data.data()!["unknown words"];
        else
          wordlist = data.data()!["wordsetB"];
        words = wordlist.keys.toList();
      });

      final translator = new GoogleTranslator();
      for (var val in wordlist.values) {
        transWords.add(val["translation"]);
      }
      print(transWords);

      tmpList.addAll(words);

      _loaded = true;

      return words;
    } else {
      return tmpList;
    }
  }

  _reviewWord(BuildContext context, String word) async {
    String storeRef;
    _setIsA ? storeRef = 'unknown words' : storeRef = 'wordsetB';
    wordlist[word]['understand'] = false;
    await FirebaseFirestore.instance
        .collection('ver1.0.0')
        .doc(uid)
        .set({storeRef: wordlist}, SetOptions(merge: true));
    Navigator.of(context).pop();
  }

  _buildConfirmationDialog(BuildContext context, String word, String content) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(word),
            content: Text(content),
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                  child: Text('Yes'),
                  onPressed: () => _reviewWord(context, word))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.autorenew),
            onPressed: () {
              setState(() {});
            },
          )
        ],
      ),
      body: FutureBuilder(
          future: _load(),
          builder: (BuildContext context, AsyncSnapshot data) {
            if (!data.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                  child: ListView.builder(
                      itemCount: data.data.length,
                      shrinkWrap: true,
                      primary: false,
                      itemBuilder: (BuildContext context, index) {
                        return ListTile(
                            title: Text(
                              data.data[index],
                              style: TextStyle(fontSize: 22.0),
                            ),
                            trailing: Text(
                              transWords[index],
                              style: TextStyle(fontSize: 22.0),
                            ),
                            onTap: () => _buildConfirmationDialog(
                                context, data.data[index], 'もう一度復習を行いますか？')
                            //subtitle: Text(wordlist[data.data[index]]['title']),
                            );
                      }));
            }
          }),
    );
  }
}
