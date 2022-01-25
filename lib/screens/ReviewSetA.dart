import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class ReviewSetA extends StatefulWidget {
  @override
  ReviewSetAState createState() => ReviewSetAState();
}

class ReviewSetAState extends State<ReviewSetA> {
  int _currentPage = 0;
  int _maxPage = 0;

  late String _uid;
  String _language = "Japanese";
  bool _called = false;
  bool _showAppBar = true;
  bool _showJpn = false;
  bool _nextPage = true;
  late List<String> words;
  late List translate_list;
  List indexList = [];
  List answerdFlag = [];
  List<CachedNetworkImageProvider> imageList = [];
  List<CachedNetworkImageProvider> jpnList = [];

  double scale = 0.0;
  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;
  double _savedVal = 1.0;

  PageController _pageController = PageController(initialPage: 0);
  late List<TextEditingController> translationController;
  Map<String, dynamic> wordsList = new Map();
  late SharedPreferences _sharedPreferences;

  @override
  void initState() {
    super.initState();
  }

  Future<List<dynamic>> _future(BuildContext context) async {
    if (!_called) {
      var result = [];
      jpnList = [];
      _sharedPreferences = await SharedPreferences.getInstance();
      _uid = _sharedPreferences.getString('uid')!;

      await FirebaseFirestore.instance
          .collection("shozemi_words")
          .doc(_uid)
          .get()
          .then((snap) async {
        var comicRef = FirebaseFirestore.instance.collection('comic_eng');
        var jpnRef = FirebaseFirestore.instance.collection('comic_jpn');

        var shuffleList = new List.generate(32, (i) => i + 1);
        shuffleList.shuffle(Random());
        wordsList = snap.data()!["unknown_words"];
        translationController = new List.generate(
            shuffleList.length, (i) => new TextEditingController());

        int a = 0;
        for (var i = 0; i < shuffleList.length; i++) {
          var index = shuffleList[i];
          if (!wordsList['$index']["understand"]) {
            result.add(wordsList['$index']['word']);
            indexList.add("$index");
            translationController[a].text = wordsList['$index']["translation"];
            a++;

            print(
                "${wordsList['$index']['word']} : ${wordsList['$index']['title']}");
            await comicRef.doc(wordsList['$index']['title']).get().then((data) {
              for (var j = 0; j < 2; j++) {
                var page = (j == 0)
                    ? wordsList["$index"]['page'] - 1
                    : wordsList["$index"]['page'];
                var configuration = createLocalImageConfiguration(context);
                imageList.add(new CachedNetworkImageProvider(
                    data['1'][wordsList['$index']['episode'].toString()][page])
                  ..resolve(configuration));
              }
            });

            await jpnRef.doc(wordsList['$index']['title']).get().then((data) {
              for (var j = 0; j < 2; j++) {
                var page = (j == 0)
                    ? wordsList["$index"]['page'] - 1
                    : wordsList["$index"]['page'];
                var configuration = createLocalImageConfiguration(context);

                jpnList.add(new CachedNetworkImageProvider(
                    data['1'][wordsList['$index']['episode'].toString()][page])
                  ..resolve(configuration));
              }
            });
          }
        }
      });

      words = [];
      result.forEach((val) => words.add(val));

      translate_list = new List.generate(words.length, (i) => false);
      answerdFlag = new List.generate(words.length, (i) => false);

      _maxPage = imageList.length;
      /* if (_maxPage != 0) {
        _called = true;
      } else {
        await Future.delayed(Duration(seconds: 1));
        //setState(() {});
      } */
      setState(() {
        _called = true;
      });
      return imageList;
    } else {
      return imageList;
    }
  }

  _onTapScreen() {
    setState(() {
      _showAppBar = _showAppBar ? false : true;
    });
  }

  _onPageChanged(int index, int maxPage) async {
    if (index == _maxPage) {
      Navigator.of(context).pop();
    }
    setState(() {
      _currentPage = index;
      //print('current : $_currentPage');
    });
  }

  _onTapOK(int index) async {
    wordsList[indexList[index].toString()]["understand"] = true;
    if (wordsList[indexList[index].toString()]["rememberd"] == null)
      wordsList[indexList[index].toString()]["rememberd"] = 0;
    wordsList[indexList[index].toString()]["rememberd"]++;
    setState(() {
      answerdFlag[index] = true;
    });
    await FirebaseFirestore.instance
        .collection("shozemi_words")
        .doc(_uid)
        .update({"unknown_words": wordsList});
  }

  _onTapNo(int index) async {
    wordsList[indexList[index].toString()]["understand"] = false;
    if (wordsList[indexList[index].toString()]["review"] == null)
      wordsList[indexList[index].toString()]["review"] = 0;
    wordsList[indexList[index].toString()]["review"]++;

    setState(() {
      answerdFlag[index] = true;
    });
    await FirebaseFirestore.instance
        .collection("shozemi_words")
        .doc(_uid)
        .update({"unknown_words": wordsList});
  }

  _toggleNextPage() {
    _nextPage = !_nextPage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _showAppBar
            ? AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                actions: [
                  //Text("${words.length}/${_maxPage / 2}"),
                  FlatButton(
                    child: Text(
                      _language,
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      setState(() {
                        if (_showJpn) {
                          _showJpn = false;
                          _language = "Japanese";
                        } else {
                          _showJpn = true;
                          _language = "English";
                        }
                      });
                    },
                  )
                ],
              )
            : null,
        body: Column(
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  FutureBuilder(
                    future: _future(context),
                    builder: (BuildContext context, AsyncSnapshot imageURL) {
                      if (!imageURL.hasData) {
                        return Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("読み込みに時間がかかることがあります"),
                            Container(
                              padding: EdgeInsets.all(8.0),
                            ),
                            CircularProgressIndicator()
                          ],
                        ));
                      } else {
                        return GestureDetector(
                          onTap: () => _onTapScreen(),
                          onScaleStart: (details) {
                            _baseScaleFactor = _scaleFactor;
                          },
                          onScaleUpdate: (details) {
                            setState(() {
                              _scaleFactor = _baseScaleFactor * details.scale;
                            });
                          },
                          child: PageView.builder(
                              controller: _pageController,
                              itemCount: imageURL.data.length + 2,
                              reverse: true,
                              onPageChanged: (int index) =>
                                  _onPageChanged(index, imageURL.data.length),
                              itemBuilder: (BuildContext context, int index) {
                                if (index < imageURL.data.length) {
                                  CachedNetworkImageProvider image =
                                      imageURL.data[index];
                                  return PhotoView(
                                    imageProvider: image,
                                    maxScale:
                                        PhotoViewComputedScale.covered * 1.5,
                                    minScale: PhotoViewComputedScale.contained,
                                  );
                                }
                                if (index == imageURL.data.length) {
                                  return _lastPage(context);
                                }
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }),
                        );
                      }
                    },
                  ),
                  _showJpn
                      ? PhotoView(
                          imageProvider: jpnList[_currentPage],
                          maxScale: PhotoViewComputedScale.covered * 1.5,
                          minScale: PhotoViewComputedScale.contained,
                        )
                      : Container(
                          /* padding: EdgeInsets.all(16.0),
                    child: Text("$_currentPage/$_maxPage", style: TextStyle(color: Colors.white),),
                  */
                          ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: _called ? _wordCard(context) : Container(),
            )
          ],
        ));
  }

  Widget _wordCard(BuildContext context) {
    return Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.black, width: 1.5)),
        child: (answerdFlag[(_currentPage / 2).floor()])
            ? Center(
                child: Text(
                  "← Next word",
                  style: TextStyle(fontSize: 30.0),
                ),
              )
            : Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            words[(_currentPage / 2).floor()],
                            style: TextStyle(fontSize: 20.0),
                          ),
                          translate_list[(_currentPage / 2).floor()]
                              ? _translatorTile((_currentPage / 2).floor())
                              : _translateButton((_currentPage / 2).floor()),
                        ],
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          RaisedButton(
                            child: Text("NO"),
                            color: Colors.red,
                            onPressed: () =>
                                _onTapNo((_currentPage / 2).floor()),
                          ),
                          RaisedButton(
                            child: Text("OK"),
                            color: Colors.green,
                            onPressed: () =>
                                _onTapOK((_currentPage / 2).floor()),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ));
  }

  _translate(String s, int index) async {
    print(index);
    print(translationController[index].text);
    setState(() {
      translate_list[index] = true;
    });
  }

  Widget _translateButton(int index) {
    return RaisedButton(
      child: Text("translate"),
      color: Theme.of(context).primaryColorLight,
      onPressed: () =>
          _translate(words[(_currentPage / 2).floor()].toString(), index),
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
            onSubmitted: (String s) => {},
            decoration: const InputDecoration(
              border: const UnderlineInputBorder(),
            ),
          ),
        ),
        /* IconButton(
          icon: Icon(Icons.input),
          onPressed: () {},
        ) */
      ],
    );
  }

  Widget _lastPage(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            '最後のページです',
            style: TextStyle(fontSize: 30.0),
          ),
          Text(
            '← スワイプして終了',
            style: TextStyle(fontSize: 30.0),
          )
        ],
      )),
    );
  }
}
