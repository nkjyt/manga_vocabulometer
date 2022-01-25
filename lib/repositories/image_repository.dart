import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangavocabulometer/manga/Manga.dart';

class ImageRepository {
  Future<List<String>> getImagesENG(Manga manga, int selectedEpisode) async {
    List<String> images = [];
    print(manga.episode);
    try {
      await FirebaseFirestore.instance
          .collection("comic_eng")
          .doc(manga.title)
          .get()
          .then((snap) {
        if (snap.exists) {
          images = snap.data()!['1'][selectedEpisode.toString()].cast<String>();
          print("loading ENG images");
          return images;
        }
      });
    } catch (e) {
      print(e);
    }
    return images;
  }

  Future<List<String>> getImagesJPN(Manga manga, int selectedEpisode) async {
    List<String> images = [];
    print(manga.episode);
    try {
      await FirebaseFirestore.instance
          .collection("comic_jpn")
          .doc(manga.title)
          .get()
          .then((snap) {
        if (snap.exists) {
          images = snap.data()!['1'][selectedEpisode.toString()].cast<String>();
          print("loading JPN images");
          return images;
        }
      });
    } catch (e) {
      print(e);
    }
    return images;
  }
  /*  return await FirebaseFirestore.instance
        .collection("comic_eng")
        .doc(manga.title)
        .get()
        .then((snap) {
      if (snap.exists) {
        return images = snap.data()!['1'][manga.episode.toString()];
      }
      return images;
    });
  } */
}
