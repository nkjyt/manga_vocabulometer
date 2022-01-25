import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mangavocabulometer/manga/Manga.dart';
import 'package:mangavocabulometer/screens/HomePage.dart';
import 'package:mangavocabulometer/screens/MangaScreen.dart';
import 'MangaView.dart';

final selectedEpisodeProvider = StateProvider((ref) => 0);

class EpisordSelect extends HookWidget {
  EpisordSelect(this.manga);

  Manga manga;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(manga.dislpay_title),
      ),
      body: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[_EpisordList(context)],
          )),
    );
  }

  Widget _EpisordList(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: manga.episode,
        itemBuilder: (BuildContext context, int index) {
          return HookBuilder(builder: (BuildContext context) {
            final selected = useProvider(selectedEpisodeProvider);
            final mangaProvider = useProvider(mangaDataProvider);
            return ListTile(
              title: Text(
                "Ep  :  ${index + 1}",
                style: TextStyle(fontSize: 20.0),
              ),
              onTap: () {
                selected.state = index + 1;
                mangaProvider.state = manga;
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (context) {
                  //return new MangaView(manga.title, index + 1);
                  return new MangaScreen();
                }));
              },
            );
          });
        },
      ),
    );
  }

}
