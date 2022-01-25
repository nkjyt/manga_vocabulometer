import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mangavocabulometer/Notifier/images_notifier.dart';
import 'package:mangavocabulometer/screens/EpisordSelect.dart';
import 'dart:convert';
import 'dart:async';
import 'package:mangavocabulometer/screens/Feedback.dart';
import 'package:mangavocabulometer/screens/HomePage.dart';
import 'package:mangavocabulometer/screens/MangaView.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final pageNotifier = StateProvider((ref) => 0);
final isJPNNotifier = StateProvider((ref) => false);

class MangaScreen extends HookWidget {
  Future<List<CachedNetworkImageProvider>> _loadImages(
      BuildContext context) async {
    List<CachedNetworkImageProvider> imageList = [];
    final manga = useProvider(mangaDataProvider).state;
    try {
      await FirebaseFirestore.instance
          .collection("comic_eng")
          .doc(manga.title)
          .get()
          .then((snap) {
        if (snap.exists) {
          List<dynamic> list = snap.data()!['1'][manga.episode.toString()];
          for (int i = 0; i < list.length; i++) {
            var configuration = createLocalImageConfiguration(context);
            imageList.add(new CachedNetworkImageProvider(list[i])
              ..resolve(configuration));
          }
          return imageList;
        }
      });
    } catch (e) {
      print(e);
    }
    return imageList;
  }

  _onPageChanged(int index) {
    print(index);
  }

  @override
  Widget build(BuildContext context) {
    final manga = useProvider(mangaDataProvider);
    final images = useProvider(imagesNotifierProvider);
    final imagesProvider = useProvider(imagesNotifierProvider.notifier);
    final jpn_images = useProvider(jpnImagesNotifierProvider);
    final jpnImagesProvider = useProvider(jpnImagesNotifierProvider.notifier);
    final page = useProvider(pageProvider);
    final selected = useProvider(selectedEpisodeProvider);
    final isJPN = useProvider(isJPNNotifier).state;

    useEffect(() {
      imagesProvider.fetchData(context, manga.state, selected.state);
      jpnImagesProvider.fetchData(context, manga.state, selected.state);
      return null;
    }, const []);

    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
                flex: 11,
                child: Stack(
                  children: [
                    PageView.builder(
                        reverse: true,
                        onPageChanged: (int index) {
                          print(index);
                          page.state = index;
                        },
                        itemCount: images.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (index < images.length) {
                            return PhotoView(
                              imageProvider: images[index],
                              maxScale: PhotoViewComputedScale.covered * 1.8,
                              minScale: PhotoViewComputedScale.contained,
                              loadingBuilder: (context, event) => Center(
                                child: Container(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );
                            /* return CachedNetworkImage(
                imageUrl: images[index],
                imageBuilder: (context, imageProvider) =>
                    PhotoView(imageProvider: imageProvider),
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Center(
                  child: Icon(Icons.error),
                ),
              ); */
                          }
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }),
                    //JPN images
                    Visibility(
                        visible: isJPN,
                        child: PhotoView(
                          imageProvider: jpn_images[page.state],
                          maxScale: PhotoViewComputedScale.covered * 1.8,
                          minScale: PhotoViewComputedScale.contained,
                        ))
                  ],
                ))
          ],
        ));
  }

/*   HookWidget jpnPage(BuildContext context) {
    final isJPN = useProvider(isJPNNotifier).state;
    final page = useProvider(pageNotifier).state;
    @override
    Widget build(BuildContext context) {
      return Visibility(
          child: PhotoView(
        imageProvider: NetworkImage(""),
        maxScale: PhotoViewComputedScale.covered * 1.8,
        minScale: PhotoViewComputedScale.contained,
        loadingBuilder: (context, event) => Center(
          child: Container(
            child: CircularProgressIndicator(),
          ),
        ),
      ));
    }
  } */
}
