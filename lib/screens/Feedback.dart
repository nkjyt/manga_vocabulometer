import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translator/translator.dart';
import 'package:mangavocabulometer/utils/strings.dart';

enum difficulty {
    Easy,
    Normal,
    Hard
  }

class FeedbackPage extends StatefulWidget {
  String title;
  int episode;
  List unknownWords;
  Map inputWords;
  Duration time;

  FeedbackPage(
      this.title, this.episode, this.unknownWords, this.time, this.inputWords);

  @override
  State<StatefulWidget> createState() {
    return FeedbackPageState(this.title, this.episode, this.unknownWords,
        this.time, this.inputWords);
  }
}

class FeedbackPageState extends State<StatefulWidget> {
  String title;
  String _difficulty = 'Easy';
  late String _uid;
  int episode;
  List unknownWords;
  Map inputWords;
  Duration time;
  bool _isMadeList = false;
  List _wordlist = [];
  List _comicWord = [];
  List<Map> easyQ = [];
  List<Map> normalQ = [];
  List<Map> hardQ = [];
  List<String> _unknownWords = [];

  Map<String, dynamic> _userWordList = new Map();
  Map<String, bool> _unkownBool = new Map();

  late File jsonFile;
  late Directory dir;
  String fileName = "input user id";
  bool fileExists = false;
  late Map<String, dynamic> fileContent;

  List<String> stopWords = [
    'a',
    'about',
    'above',
    'after',
    'again',
    'against',
    'all',
    'am',
    'an',
    'and',
    'any',
    'are',
    'aren\'t',
    'as',
    'at',
    'be',
    'because',
    'been',
    'before',
    'being',
    'below',
    'between',
    'both',
    'but',
    'by',
    'can',
    'can\'t',
    'cant',
    'cannot',
    'could',
    'couldn\'t',
    'couldnt',
    'did',
    'didn\'t',
    'didnt',
    'do',
    'does',
    'doesn\'t',
    'doing',
    'don\'t',
    'dont',
    'down',
    'during',
    'each',
    'few',
    'for',
    'from',
    'further',
    'had',
    'hadn\'t',
    'has',
    'hasn\'t',
    'have',
    'haven\'t',
    'having',
    'he',
    'he\'d',
    'he\'ll',
    'he\'s',
    'her',
    'here',
    'here\'s',
    'hers',
    'herself',
    'him',
    'himself',
    'his',
    'how',
    'how\'s',
    'i',
    'i\'d',
    'i\'ll',
    'i\'m',
    'i\'ve',
    'if',
    'in',
    'into',
    'is',
    'isn\'t',
    'it',
    'it\'s',
    'its',
    'itse\'lf',
    'let\'s',
    'me',
    'more',
    'most',
    'mustn\'t',
    'my',
    'myself',
    'no',
    'nor',
    'not',
    'of',
    'off',
    'on',
    'once',
    'only',
    'or',
    'other',
    'ought',
    'our',
    'ours',
    'ourselves',
    'out',
    'over',
    'own',
    'same',
    'shan\'t',
    'she',
    'she\'d',
    'she\'ll',
    'she\'s',
    'should',
    'shouldn\'t',
    'so',
    'some',
    'such',
    'se',
    'than',
    'that',
    'that\'s',
    'the',
    'their',
    'theirs',
    'them',
    'themselves',
    'then',
    'there',
    'there\'s',
    'these',
    'they',
    'they\'d',
    'they\'ll',
    'they\'re',
    'they\'ve',
    'this',
    'those',
    'through',
    'to',
    'too',
    'under',
    'until',
    'up',
    'very',
    'was',
    'wasn\'t',
    'we',
    'we\'d',
    'we\'ll',
    'we\'re',
    'we\'ve',
    'were',
    'weren\'t',
    'what',
    'what\'s',
    'when',
    'when\'s',
    'where',
    'where\'s',
    'which',
    'while',
    'who',
    'who\'s',
    'whom',
    'why',
    'why\'s',
    'with',
    'won\'t',
    'would',
    'wouldn\'t',
    'you',
    'you\'d',
    'you\'ll',
    'you\'re',
    'you\'ve',
    'your',
    'yours',
    'yourself',
    'yourselves',
  ];

  late SharedPreferences _sharedPreferences;

  FeedbackPageState(
      this.title, this.episode, this.unknownWords, this.time, this.inputWords);

  @override
  void initState() {
    _loadWordLists();
    _loadUserWordList();
    _initializeFileStatus();
    super.initState();
  }

  void _onChanged(String e) => setState(() {
        _difficulty = e;
      });
  void _handleCheckList(bool val, String s) {
    setState(() {
      _unkownBool[s] = val;
    });
  }

  _initializeFileStatus() async {
    //jsonファイルに関する初期化
    _sharedPreferences = await SharedPreferences.getInstance();
    _uid = _sharedPreferences.getString('uid')!;
    fileName = _uid + "-wordlist.json";
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
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

  _putUserWordList() async {
    if (fileExists) {
      print('file exists');
      Map<String, dynamic> jsonFileContent =
          json.decode(jsonFile.readAsStringSync());
      jsonFileContent = _userWordList;
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    } else {
      print("File does not exist");
      _createFile(_userWordList, dir, fileName);
    }
    //  put data
    final firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref().child("wordFreqList/${_uid}-wordlist.json");
    final firebase_storage.UploadTask uploadTask = ref.putFile(jsonFile);
     try {
      firebase_storage.TaskSnapshot snapshot = await uploadTask;
    } catch (e) {
      print(uploadTask.snapshot);
      print(e);
    }
  }

  _loadWordLists() async {
    String comicWordPath =
        "wordlist/${title}/${title}_ep${episode}_wordlist.json";
    //print(comicWordPath);
    final comicWordRef = firebase_storage.FirebaseStorage.instance.ref().child(comicWordPath);
    String url = await comicWordRef.getDownloadURL();
    await http.get(Uri.parse(url)).then((response) {
      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");
      var tmp = [];
      Map<String, dynamic> wordlist = json.decode(response.body);
      wordlist.forEach((key, value) {
        tmp.add(value);
        _comicWord.add(value);
      });
      print(_comicWord);
      for (var i = 1; i < tmp.length; i++) {
        //1つの配列に統合
        for (var j = 0; j < tmp[i].length; j++) {
          _wordlist.add(tmp[i][j]);
        }
      }
    });
  }

  _loadUserWordList() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _uid = _sharedPreferences.getString('uid')!;
    String userWordListPath = "wordFreqList/" + _uid + "-wordlist.json";
    final userWordListRef =
        firebase_storage.FirebaseStorage.instance.ref().child(userWordListPath);
    String url = await userWordListRef.getDownloadURL();
    http.get(Uri.parse(url)).then((response) {
      _userWordList = json.decode(response.body);
      var keyCheck = [];

      for (var i = 0; i < _wordlist.length; i++) {
        if (_userWordList[_wordlist[i]] != null) {
          if (keyCheck.indexOf(_wordlist[i]) == -1) {
            //keyCheckに単語があるか
            keyCheck.add(_wordlist[i]);
            var value = _wordlist[i].toString();
            if (_userWordList[_wordlist[i]]["understand"] <= 0.95) {
              //hard
              hardQ.add({
                "word": value,
                "rank": _userWordList[_wordlist[i]]["rank"],
                "understand": 1.00,
                "checked": false
              });
              if (_userWordList[_wordlist[i]]["understand"] <= 0.90) {
                //normal
                normalQ.add({
                  "word": value,
                  "rank": _userWordList[_wordlist[i]]["rank"],
                  "understand": 1.00,
                  "checked": false
                });
                if (_userWordList[_wordlist[i]]["understand"] <= 0.85) {
                  //easy
                  easyQ.add({
                    "word": value,
                    "rank": _userWordList[_wordlist[i]]["rank"],
                    "understand": 0.95,
                    "checked": false
                  });
                }
              }
            } //hard
          }
        }
      }

      for (var value1 in easyQ) {
        print(value1);
        _unknownWords.add(value1["word"]);
        _unkownBool[value1["word"]] = false;
      }
      //　前画面で選択していた単語を選択済みにする処理
      for (var val in unknownWords) {
        if (_unknownWords.indexOf(val) == -1) _unknownWords.add(val);
        _unkownBool[val] = true;
      }
      for (var val in inputWords.keys) {
        if (_unknownWords.indexOf(val) == -1) _unknownWords.add(val);
        _unkownBool[val] = true;
      }
      print(unknownWords);
      setState(() {
        _isMadeList = true;
      });
    });
  }

  void _onCahngedDificulty(String? e) {
    print(e);
    setState(() {
      _difficulty = e! ;
      _setUnknownWords();
    });
  }

  _setUnknownWords() async {
    _unknownWords = [];
    _unkownBool = new Map();
    switch (_difficulty) {
      case "Easy":
        for (var value1 in easyQ) {
          _unknownWords.add(value1["word"]);
          _unkownBool[value1["word"]] = false;
        }
        break;
      case "Normal":
        for (var value1 in normalQ) {
          _unknownWords.add(value1["word"]);
          _unkownBool[value1["word"]] = false;
        }
        break;
      case "Hard":
        for (var value1 in hardQ) {
          _unknownWords.add(value1["word"]);
          _unkownBool[value1["word"]] = false;
        }
        break;
    }
    for (var val in unknownWords) {
      if (_unknownWords.indexOf(val) == -1) _unknownWords.add(val);
      _unkownBool[val] = true;
    }
    for (var val in inputWords.keys) {
      if (_unknownWords.indexOf(val) == -1) _unknownWords.add(val);
      _unkownBool[val] = true;
    }

    setState(() {});
  }

  _submit() async {
    // Map<String, dynamic> unkownwords = new Map();
    Map<String, dynamic> upload_words = new Map();

    var firestoreRef =
        FirebaseFirestore.instance.collection(Strings.collectionName).doc(_uid);

    await FirebaseFirestore.instance
        .collection(Strings.collectionName)
        .doc(_uid)
        .get()
        .then((snapshot) async {
      upload_words.addAll(snapshot.data()!['unknown_words']);
      _unkownBool.forEach((key, value) async {
        if (value) {
          print(key);
          int pageIndex = _searchIndex(key)!;
          String s = await _translator(key);
          upload_words[key] = {
            "understand": false,
            "title": title,
            "episode": episode,
            "page": pageIndex + 2,
            "rank": _userWordList[key]["rank"],
            "translation": s,
            "review": 0,
            "rememberd": 0,
          };
          await firestoreRef
              .set({"unknown_words": upload_words}, SetOptions(merge: true));
          //firestoreRef.data["unknown_words"][key] = { "understand" : false };
        }
      });
      /* await Firestore.instance
          .collection("unknown_words")
          .document(_uid)
          .setData({"unknown_words": upload_words}, merge: true); */
    });

    for (var val in _comicWord) {
      for (var word in val) {
        if (_userWordList[word] != null) {
          _userWordList.update(
              word.toString(),
              (exist) => {
                    "rank": exist['rank'],
                    "parts": exist['parts'],
                    "understand": 1.00
                  },
              ifAbsent: () => print("naidesu"));
        } else {
          continue;
        }

        _userWordList.update(
            word.toString(),
            (exist) => {
                  "rank": exist['rank'],
                  "parts": exist['parts'],
                  "understand": 1.00
                });
      }
    }

    switch (_difficulty) {
      case "Easy":
        for (var value1 in easyQ) {
          _userWordList.update(
              value1["word"],
              (exist) => {
                    "rank": exist['rank'],
                    "parts": exist['parts'],
                    "understand": 1.00
                  });
        }
        break;
      case "Normal":
        for (var value1 in normalQ) {
          _userWordList.update(
              value1["word"],
              (exist) => {
                    "rank": exist['rank'],
                    "parts": exist['parts'],
                    "understand": 1.00
                  });
        }
        break;
      case "Hard":
        for (var value1 in hardQ) {
          _userWordList.update(
              value1["word"],
              (exist) => {
                    "rank": exist['rank'],
                    "parts": exist['parts'],
                    "understand": 1.00
                  });
        }
        break;
    }

    var userLog = {
      title: {
        episode.toString(): {"difficulty": _difficulty, "time": time.toString()}
      }
    };

    await FirebaseFirestore.instance
        .collection('Log')
        .doc(_uid)
        .set({'Log': userLog}, SetOptions(merge: true));

    _putUserWordList();

    Navigator.of(context).pushReplacementNamed("/HomePage");
  }

  Future<String> _translator(String word) async {
    var translated;
    final translator = new GoogleTranslator();
    await translator.translate(word, to: 'ja').then((t) {
      translated = t.toString();
    });
    return translated;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Feedback'),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Text('このチャプターをどう感じましたか？',
                        style: TextStyle(fontSize: 24.0)),
                  ),
                  Divider(),
                  _isMadeList
                      ? _difficultyList(context)
                      : Center(
                          child: CircularProgressIndicator(),
                        ),
                  Divider(),
                  Center(
                      child: Text(
                    "未知単語にチェック",
                    style: TextStyle(fontSize: 24.0),
                  )),
                  Divider(),
                  _isMadeList ? _unknownWordsList() : Text(""),
                  _isMadeList ? _submitButton() : Text('')
                ],
              )),
        ),
        onWillPop: () async {
          return true;
        });
  }

  Widget _unknownWordsList() {
    return ListView(
      primary: false,
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      children: _unknownWords
          .map((text) => CheckboxListTile(
                title: Text(
                  text,
                  style: TextStyle(fontSize: 20.0),
                ),
                value: _unkownBool[text],
                onChanged: (val) {
                  _handleCheckList(val!, text);
                },
              ))
          .toList(),
    );
  }

  Widget _submitButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Divider(),
        ConstrainedBox(
          constraints: BoxConstraints.expand(height: 60.0),
          child: RaisedButton(
            child: Text("Submit"),
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            onPressed: () => _submit(),
          ),
        ),
      ],
    );
  }

  Widget _difficultyList(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioListTile(
          value: 'Easy',
          groupValue: _difficulty,
          title: Text('Easy', style: TextStyle(fontSize: 20.0)),
          onChanged: _onCahngedDificulty,
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        RadioListTile(
          value: 'Normal',
          groupValue: _difficulty,
          title: Text('Normal', style: TextStyle(fontSize: 20.0)),
          onChanged: _onCahngedDificulty,
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        RadioListTile(
          value: 'Hard',
          groupValue: _difficulty,
          title: Text('Hard', style: TextStyle(fontSize: 20.0)),
          onChanged: _onCahngedDificulty,
          controlAffinity: ListTileControlAffinity.trailing,
        ),
      ],
    );
  }

  int? _searchIndex(String str) {
    for (var key in inputWords.keys) {
      if (key == str) return inputWords[key] - 2;
    }
    for (var i = 1; i < _comicWord.length; i++) {
      for (var j = 0; j < _comicWord[i].length; j++) {
        if (str == _comicWord[i][j]) {
          return 2 * i - 1;
        }
      }
    }
  }
}
