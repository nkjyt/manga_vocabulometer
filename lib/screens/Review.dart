import 'package:flutter/material.dart';
import 'package:mangavocabulometer/screens/Flashcard.dart';
import 'package:mangavocabulometer/widget/BottomTabBar.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mangavocabulometer/utils/strings.dart';


class ReviewScreen extends StatefulWidget {
  String title;
  int episode;
  int page;
  String word;

  ReviewScreen(this.title, this.episode, this.page, this.word);

  @override
  State<StatefulWidget> createState() {
    return ReviewScreenState(this.title, this.episode, this.page, this.word);
  }
}

class ReviewScreenState extends State<StatefulWidget> {
  String title;
  int episode;
  int page;
  String word;
  String _language = "Japanese";
  bool _showAppBar = true;
  bool _showJpn = false;
  bool _isParticipants = false;
  var jpn_list;
  late String _uid;
  late SharedPreferences _sharedPreferences;

  double scale = 0.0;
  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;
  double _savedVal = 1.0;

  ReviewScreenState(this.title, this.episode, this.page, this.word);

  int _currentPage = 0;
  PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _checkParticipants();
  }

  _checkParticipants() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _uid = _sharedPreferences.getString('uid')!;
    await FirebaseFirestore.instance
        .collection("shozemi_words")
        .doc(_uid)
        .get()
        .then((snapshot) {
      _isParticipants = snapshot.exists ? true : false;
    });
    print(word);
  }

  Future<List<CachedNetworkImageProvider>> _loadImageList(
      BuildContext context) async {
    var comicRef =
        await FirebaseFirestore.instance.collection('comic_eng').doc(title).get();
    var japaneseRef =
        await FirebaseFirestore.instance.collection('comic_jpn').doc(title).get();
    List<dynamic> list = comicRef.data()!['1'][episode.toString()];
    List<dynamic> list_jpn = japaneseRef.data()!['1'][episode.toString()];

    List<CachedNetworkImageProvider> imageList = [];
    List<CachedNetworkImageProvider> imageList_jpn = [];

    for (int i = page - 1; i < page + 1; i++) {
      var configuration = createLocalImageConfiguration(context);
      imageList
          .add(new CachedNetworkImageProvider(list[i])..resolve(configuration));
      imageList_jpn.add(
          new CachedNetworkImageProvider(list_jpn[i])..resolve(configuration));
    }
    jpn_list = imageList_jpn;

    return imageList;
  }

  _onPageChanged(BuildContext context, int index, int maxPage) async {
    setState(() {
      _currentPage = index;
    });
    if (index == maxPage + 1) {
      _sharedPreferences = await SharedPreferences.getInstance();
      _uid = _sharedPreferences.getString('uid')!;
      String col = _isParticipants ? "shozemi_words" : Strings.collectionName;

      await FirebaseFirestore.instance
          .collection(col)
          .doc(_uid)
          .get()
          .then((snapshot) async {
        var unknownWords = snapshot.data()!["unknown_words"];
        if (unknownWords[word]["review"] == null)
          unknownWords[word]["review"] = 0;
        unknownWords[word]["review"]++;
        await FirebaseFirestore.instance
            .collection(col)
            .doc(_uid)
            .update({"unknown_words": unknownWords});
      });
      Navigator.of(context).pop();
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
    // TODO: implement build
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _showAppBar
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    _language,
                    style: TextStyle(color: Colors.white),
                  ),
                  //color: Colors.white,
                  onPressed: () {
                    setState(() {
                      if (_showJpn) {
                        if (_currentPage != 4) {
                          _showJpn = false;
                          _language = "Japanese";
                        }
                      } else {
                        _showJpn = true;
                        _language = "English";
                      }
                    });
                  },
                ),
              ],
            )
          : null,
      body: Stack(
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
                      onPageChanged: (int index) =>
                          _onPageChanged(context, index, imageURL.data.length),
                      itemBuilder: (BuildContext context, int index) {
                        if (index < imageURL.data.length) {
                          CachedNetworkImageProvider image =
                              imageURL.data[index];
                          return PhotoView(
                            imageProvider: image,
                            maxScale: PhotoViewComputedScale.covered * 1.5,
                            minScale: PhotoViewComputedScale.contained,
                          );
                        }
                        if (index == imageURL.data.length) {
                          return _lastPage();
                        } else {
                          //_navigator(context);
                          return Center(
                            child: CircularProgressIndicator(),
                          );
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
    );
  }

  Widget _lastPage() {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            'Last Page',
            style: TextStyle(fontSize: 30.0),
          ),
          Text(
            '← swipe to finish',
            style: TextStyle(fontSize: 30.0),
          )
        ],
      )),
    );
  }
}
