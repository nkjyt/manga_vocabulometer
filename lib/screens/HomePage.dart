import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangavocabulometer/screens/EpisordSelect.dart';
import 'package:mangavocabulometer/manga/Manga.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mangavocabulometer/utils/App_utils.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

final isEnglishProvider = StateProvider((ref) => true);
final mangaDataProvider = StateProvider(
    (ref) => Manga("key", "title", "japanese", "dislpay_title", "url", 0));

class HomePage extends HookWidget {
  @override
  void initState() {
    //super.initState();
  }

  Future<List> _loadData() async {
    List<Manga> mangaData = [];
    Map<String, dynamic> nameList = {};
    Map<String, dynamic> urlListData = {};
    await FirebaseFirestore.instance
        .collection('title')
        .doc('name_list')
        .get()
        .then((snap) {
      if (snap.data() != null) {
        nameList = snap.data()!;
      }
    }).catchError((e) => print(e.toString()));

    await FirebaseFirestore.instance
        .collection('comic_assets')
        .doc('title_image')
        .get()
        .then((snap) {
      if (snap.data() != null) {
        urlListData = snap.data()!;
      }
    });
    nameList.forEach((key, val) {
      val['url'] = urlListData[key];
      val['key'] = key;
      mangaData.add(Manga(
        key,
        val['title'],
        val['Japanese'],
        val['display_title'],
        urlListData[key],
        int.parse(val['episode']),
      ));
    });
    return mangaData;
  }

  _onTapEvent(BuildContext context, Manga manga) {
    final selectedManga = useProvider(mangaDataProvider);
    selectedManga.state = manga;

    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return EpisordSelect(manga);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, watch, child) {
            final isEnglish = watch(isEnglishProvider).state;
            return isEnglish ? Text('Choose title !') : Text('タイトルを選択');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.translate),
            onPressed: () {
              context.read(isEnglishProvider).state =
                  !context.read(isEnglishProvider).state;
            },
          )
        ],
      ),
      body: SafeArea(
        child: Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[_mangaList(context)],
            )),
      ),
    );
  }

  Widget _mangaList(BuildContext context) {
    return FutureBuilder(
      future: _loadData(),
      builder: (BuildContext context, AsyncSnapshot mangaData) {
        if (!mangaData.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (mangaData.hasError) {
          return AppUtils().buildAlertDialog(context, "エラー：データが読み込めません");
        } else {
          return Expanded(
            child: GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: mangaData.data.length,
              itemBuilder: (BuildContext context, int index) {
                return _mangaTitles(context, mangaData.data[index]);
              },
            ),
          );
          /* 
          return Expanded(child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              if (index.isOdd) return Divider();
              final i = index ~/ 2; //2で割った商
              if (i < titleData.data['title'].length) {
                return ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: titleData.data['url'][i],
                  ),
                  title: _isEnglish
                      ? Text(titleData.data['title_render'][i])
                      : Text(titleData.data['Japanese_title'][i]),
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return EpisordSelect(titleData.data['title'][i],
                        titleData.data['title_render'][i]);
                  })),
                );
              }
            },
          ));
         */
        }
      },
    );
  }

  Widget _mangaTitles(BuildContext context, Manga mangaData) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return EpisordSelect(mangaData);
        }));
      },
      child: Container(
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: Center(
          child: Stack(
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl: mangaData.url,
                ),
              ),
              _titleOnImage(mangaData)
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleOnImage(Manga manga) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: AspectRatio(
        aspectRatio: 5,
        child: Container(
          alignment: Alignment.center,
          color: Colors.grey.withOpacity(0.8),
          child: Consumer(
            builder: (context, watch, child) {
              final isEnglish = watch(isEnglishProvider).state;
              return Text(
                isEnglish ? manga.title : manga.japanese,
                style: TextStyle(fontSize: 16.0),
              );
            },
          ),
        ),
      ),
    );
  }
}
