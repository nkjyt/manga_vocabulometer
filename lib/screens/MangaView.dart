import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:convert';
import 'dart:async';
import 'package:mangavocabulometer/screens/Feedback.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


final isLoadedProvider = StateProvider((ref) => false);
final pageProvider = StateProvider((ref) => 0);
final isShowedABProvider = StateProvider((ref) => true);
final isJPN = StateProvider((ref) => false);

final baseScaleProvider = StateProvider((ref) => 1.0);
final scaleProvider = StateProvider((ref) => 1.0);

class MangaView extends StatefulWidget {
  String title;
  int episode;

  MangaView(this.title, this.episode);

  @override
  State<StatefulWidget> createState() {
    return MangaViewState(this.title, this.episode);
  }
}

class MangaViewState extends State<StatefulWidget> {
  String title;
  String _language = "Japanese";
  late String uid;
  int episode;
  int _currentPage = 0;
  int _maxPage = 0;
  bool _showAppBar = true;
  bool _showJpn = false;
  bool _loaded = false;
  List _unknownWords = [];
  Map _inputWords = new Map();
  List<Map<String, bool>> _checkBoxBool = [];
  var jpn_list;
  var _comicWords;
  var inputText;
  PageController _pageController = PageController(initialPage: 0);
  Stopwatch s = Stopwatch();

  double scale = 0.0;
  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;

  MangaViewState(this.title, this.episode);


  @override
  void initState() {
    super.initState();
    s.start();
    inputText = TextEditingController();
  }

  Future<List<CachedNetworkImageProvider>> _loadImageList(
      BuildContext context) async {
    var comicRef = await FirebaseFirestore.instance
        .collection('comic_eng')
        .doc(title)
        .get();
    var jpnRef = await FirebaseFirestore.instance
        .collection('comic_jpn')
        .doc(title)
        .get();

    List<dynamic> list = comicRef.data()!['1'][episode.toString()];
    List<dynamic> list_jpn = jpnRef.data()!['1'][episode.toString()];

    List<CachedNetworkImageProvider> imageList = [];
    List<CachedNetworkImageProvider> imageList_jpn = [];
    for (int i = 0; i < list.length; i++) {
      var configuration = createLocalImageConfiguration(context);
      imageList
          .add(new CachedNetworkImageProvider(list[i])..resolve(configuration));
      imageList_jpn.add(
          new CachedNetworkImageProvider(list_jpn[i])..resolve(configuration));
    }
    _maxPage = imageList.length;

    jpn_list = imageList_jpn;
    print(list);
    return imageList;
  }

  Future<List<dynamic>> _loadWordLists() async {
    if (!_loaded) {
      Map<String, dynamic> userWordList = new Map();
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      uid = sharedPreferences.getString('uid')!;
      String fileName = uid + "-wordlist.json";

      //get user word list
      getApplicationDocumentsDirectory().then((Directory directory) async {
        File jsonFile = new File(directory.path + "/" + fileName);
        bool FileExists = jsonFile.existsSync();
        if (FileExists) {
          // load local file
          print("true");
          userWordList = json.decode(jsonFile.readAsStringSync());
        } else {
          // load from database
          String userWordListPath = 'wordFreqList/' + uid + '-wordlist.json';
          final userWordListRef =
              FirebaseStorage.instance.ref().child(userWordListPath);
          String userUrl = await userWordListRef.getDownloadURL();
          http.get(Uri.parse(userUrl)).then((response) {
            userWordList = json.decode(response.body);
            // store the file locally
            jsonFile.writeAsStringSync(json.encode(userWordList));
          });
        }
        String comicWordPath =
            "wordlist/${title}/${title}_ep${episode}_wordlist.json";
        final comicWordRef =
            FirebaseStorage.instance.ref().child(comicWordPath);
        String url = await comicWordRef.getDownloadURL();
        await http.get(Uri.parse(url)).then((res) {
          List words = [];
          Map<String, dynamic> wordlist = json.decode(res.body);
          // remove easy words
          wordlist.forEach((key, value) {
            List<String> tmp = [];
            for (var w in value) {
              if (userWordList[w] != null) {
                if (userWordList[w]['understand'] <= 0.99) {
                  tmp.add(w);
                }
              }
            }
            //words.add(tmp);
            tmp.length != 0 ? words.add(tmp) : words.add(['']);
          }); // wordlist.forEach
          for (List val in words) {
            Map<String, bool> tmp = new Map();
            if (val.length > 0) {
              val.sort();
              tmp[val[0]] = false;
              for (var i = 1; i < val.length; i++) {
                if (val[i] == val[i - 1]) {
                  val.removeAt(i);
                  i--;
                  continue;
                }
                tmp[val[i]] = false;
              }
              _checkBoxBool.add(tmp);
            } else {
              _checkBoxBool.add(tmp);
            }
          }
          _comicWords = words;
          setState(() {
            _loaded = true;
          });
          return words;
        });
      });
    }
    return _comicWords ??= [];
  }

  _onPageChanged(BuildContext context, int index, int maxPage) async {
    setState(() {
      _currentPage = index;
    });
    if (index == maxPage + 1) {
      s.stop();
      print(s.elapsed);

      Navigator.of(context, rootNavigator: true)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return FeedbackPage(
            title, episode, _unknownWords, s.elapsed, _inputWords);
      }));
    } else {
      return null;
    }
  }

  _onTapScreen() {
    if (_showAppBar)
      setState(() {
        _showAppBar = false;
      });
    else
      setState(() {
        _showAppBar = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _showAppBar
            ? AppBar(
                backgroundColor: Colors.transparent,
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        inputText.text = "";
                        var result = await showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '未知単語の入力',
                                  ),
                                  TextField(
                                    controller: inputText,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "単語を正確に入力してください"),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: RaisedButton(
                                      child: Text("追加"),
                                      onPressed: () {
                                        if (inputText.text.trim().isNotEmpty)
                                          addToList();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  )
                                ],
                              );
                            });
                      } //_showPopup(),
                      ),
                  FlatButton(
                    child: Text(
                      _language,
                      style: TextStyle(color: Colors.white),
                    ),
                    //color: Colors.white,
                    onPressed: () {
                      setState(() {
                        if (_currentPage < _maxPage) {
                          if (_showJpn) {
                            if (_currentPage != _maxPage) {
                              _showJpn = false;
                              _language = "Japanese";
                            }
                          } else {
                            _showJpn = true;
                            _language = "English";
                          }
                        } else {}
                      });
                    },
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(12.0, 0, 12.0, 0),
                      child: Center(child: Text("$_currentPage/$_maxPage")))
                ],
              )
            : null,
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 11,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  FutureBuilder(
                    future: _loadImageList(context),
                    builder: (BuildContext context, AsyncSnapshot imageURL) {
                      if (!imageURL.hasData) {
                        return Center(child: CircularProgressIndicator());
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
                              itemCount: imageURL.data.length + 2,
                              controller: _pageController,
                              reverse: true,
                              onPageChanged: (int index) => _onPageChanged(
                                  context, index, imageURL.data.length),
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
                                } else {
                                  return _circleIndicator();
                                }
                              }),
                        );
                      }
                    },
                  ),
                  _showJpn
                      ? PhotoView(
                          imageProvider: jpn_list[_currentPage],
                          maxScale: PhotoViewComputedScale.covered * 1.5,
                          minScale: PhotoViewComputedScale.contained,
                        )
                      : Container(),
                ],
              ),
            ),
            /* Expanded(
              flex: 1,
              child: FutureBuilder(
                  future: _loadWordLists(),
                  builder: (BuildContext context, AsyncSnapshot list) {
                    if (!list.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (list == []) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      //int page = (_currentPage/2).toInt();
                      int page = _currentPage ~/ 2;
                      if (_currentPage < _maxPage) {
                        return ListView.builder(
                            key: ObjectKey(list.data[page][0]),
                            controller:
                                ScrollController(keepScrollOffset: false),
                            scrollDirection: Axis.horizontal,
                            //itemCount: list.data[page].length,
                            itemBuilder: (BuildContext context, index) {
                              if (index.isOdd) return VerticalDivider();
                              final i = index ~/ 2;
                              if (i < list.data[page].length) {
                                if (list.data[page][0] == '')
                                  return Container(
                                    width: 300,
                                    alignment: Alignment.center,
                                    child: Text('推薦された単語がありません'),
                                  );

                                return Container(
                                  width: 180,
                                  child: CheckboxListTile(
                                    title: Text(
                                      list.data[page][i],
                                      textAlign: TextAlign.center,
                                    ),
                                    value: _checkBoxBool[page]
                                        [list.data[page][i]],
                                    onChanged: (
                                      val,
                                    ) {
                                      setState(() {
                                        _checkBoxBool[page]
                                                [list.data[page][i]] =
                                            val ??= false;
                                      });
                                      _unknownWords.add(list.data[page][i]);
                                    },
                                  ),
                                );
                              } else {
                                return Container(
                                  width: 300,
                                  alignment: Alignment.center,
                                );
                              }

                              ///Text(list.data[_currentPage.toInt()][index]);
                            });
                      } else {
                        return Container(
                          color: Colors.white,
                        );
                      }
                    }
                  }),
            ), */
          ],
        ),
      ),
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

  Widget _BottomWordList(BuildContext context) {
    return FutureBuilder(
      future: _loadWordLists(),
      builder: (BuildContext context, AsyncSnapshot list) {
        if (!list.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          int page = _currentPage ~/ 2;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    itemCount: list.data[page].length,
                    itemBuilder: (BuildContext context, index) {
                      return ListTile(
                        leading: Text(""),
                        title: Text(
                          list.data[page][index],
                          style: TextStyle(fontSize: 20.0),
                        ),
                        onTap: () {
                          _unknownWords.add(list.data[page][index]);
                          Scaffold.of(context).showSnackBar(new SnackBar(
                            content: new Text(
                              list.data[page][index],
                              textAlign: TextAlign.end,
                            ),
                            duration: new Duration(seconds: 1),
                            backgroundColor: Theme.of(context).primaryColor,
                          ));
                        },
                      );

                      ///Text(list.data[_currentPage.toInt()][index]);
                    }),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _circleIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  void addToList() {
    setState(() {
      _inputWords[inputText.text] = _currentPage;
      _comicWords[_currentPage ~/ 2].insert(0, inputText.text);
      _checkBoxBool[_currentPage ~/ 2][inputText.text] = true;
    });
    print(_comicWords[_currentPage ~/ 2]);
  }
}
