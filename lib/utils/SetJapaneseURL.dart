import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

//画像のURLをfirebaseに保存するための画面
class JapanesePage extends StatefulWidget {
  @override
  JapanesePageState createState() => JapanesePageState();
}

class JapanesePageState extends State<JapanesePage> {
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
      for (var j = 0; j < 50; j++) {
        String comicWordPath =
            "comic/${titleData['title']}/ep${i}/jpn/${j.toString().padLeft(4, '0')}.png";

        await storageRef.child(comicWordPath).getDownloadURL().then((url) {
          list.add(url);
        }).catchError((e) {
          //print(list);
          j = 55;
        });
      }
      //URLList.add(list);
      URLmap[i.toString()] = list;
      //print(i + URLList[i]);
    }

    await FirebaseFirestore.instance
        .collection('comic_jpn')
        .doc(titleData['title'])
        .set({"1": URLmap});
  }

  _setICON() async {
    List list = [];
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
        .doc('title')
        .set({"url": list});
    print('set icon url');
    print(list);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Japanese URL'),
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
