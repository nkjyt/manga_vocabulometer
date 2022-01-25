import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mangavocabulometer/utils/SetJapaneseURL.dart';

//画像のURLをfirebaseに保存するための画面
class DevelopPage extends StatefulWidget {
  @override
  DevelopPageState createState() => DevelopPageState();
}

class DevelopPageState extends State<DevelopPage> {
  List title_list = [];

  @override
  void initState() {
    //super.initState();
  }

  Future<List> _getTitleList() async {
    var titleRef = await FirebaseFirestore.instance
        .collection('title')
        .doc('name_list')
        .get()
        .then((snapshot) {
      snapshot.data()!.forEach((k, v) {
        title_list.add(snapshot.data()![k]);
      });
    });
    return title_list;
  }

  _onTap(Map<String, dynamic> titleData) async {
    int number = int.parse(titleData['episode']);

    var storageRef = await FirebaseStorage.instance.ref();

    List URLList = [];
    Map<String, dynamic> URLmap = new Map();

    for (var i = 1; i < number + 1; i++) {
      List list = [];
      for (var j = 0; j < 40; j++) {
        String comicWordPath =
            "comic/${titleData['title']}/ep${i}/eng/${j.toString().padLeft(4, '0')}.png";
        await storageRef.child(comicWordPath).getDownloadURL().then((url) {
          list.add(url);
        }).catchError((e) {
          print("--------------i---------------");
          j = 45;
        });
      }
      //URLList.add(list);
      URLmap[i.toString()] = list;
      //print(i + URLList[i]);
    }

    await FirebaseFirestore.instance
        .collection('comic_eng')
        .doc(titleData['title'])
        .set({"1": URLmap});
  }

  _setICON() async {
    Map<String, dynamic> URLList = new Map();

    await FirebaseFirestore.instance
        .collection('title')
        .doc('name_list')
        .get()
        .then((snapshot) {
      snapshot.data()!.forEach((key, val) async {
        await FirebaseStorage.instance
            .ref()
            .child('cover_image/title/${snapshot.data()![key]['title']}_title.jpg')
            .getDownloadURL()
            .then((url) {
          print(key);
          URLList[key] = url;
          FirebaseFirestore.instance
              .collection('comic_assets')
              .doc('title_image')
              .set(URLList);
        });
      });
    });

/*     List list = [];
    for (var i = 0; i < title_list.length; i++) {
      await FirebaseStorage.instance
          .ref()
          .child('icon/${title_list[i]}_title_400px.png')
          .getDownloadURL()
          .then((url) {
        list.add(url);
      });
    }
    FirebaseFirestore.instance
        .collection('comic')
        .document('title')
        .setData({"url": list}, merge: true);
    print('set icon url');
    print(list); */
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.error),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) {
              return new JapanesePage();
            })),
          )
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            _mangaList(context),
            RaisedButton(
              child: Text('set icon URL'),
              onPressed: () => _setICON(),
            )
          ],
        ),
      ),
    );
  }

  Widget _mangaList(BuildContext context) {
    return FutureBuilder(
      future: _getTitleList(),
      builder: (BuildContext context, AsyncSnapshot titleData) {
        if (!titleData.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Expanded(
            child: ListView.builder(
              itemCount: titleData.data.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    title: Text(titleData.data[index]['display_title']),
                    onTap: () => _onTap(
                          titleData.data[index],
                        ));
              },
            ),
          );
        }
      },
    );
  }
}
