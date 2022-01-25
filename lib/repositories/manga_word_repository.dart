import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MangaWordRepository {

  Future<Map<String, dynamic>> getUserWord() async {
    Map<String, dynamic> userWordList = new Map();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String uid = sharedPreferences.getString('uid')!;
    String fileName = uid + "-wordlist.json";

    getApplicationDocumentsDirectory().then((Directory directory) async {
      File jsonFile = new File(directory.path + "/" + fileName);

      if (jsonFile.existsSync()) {
        userWordList = json.decode(jsonFile.readAsStringSync());
        return userWordList;
      } else {
        String userWordListPath = 'wordFreqList/' + uid + '-wordlist.json';
        final userWordListRef =
            FirebaseStorage.instance.ref().child(userWordListPath);
        String userUrl = await userWordListRef.getDownloadURL();
        http.get(Uri.parse(userUrl)).then((response) async {
          userWordList = await json.decode(response.body);
          // store the file locally
          jsonFile.writeAsStringSync(json.encode(userWordList));
          return userWordList;
        });
      }
    });
    return userWordList;
  }

  Future<Map<String, dynamic>> loadWordLists(String title, String episode) async {
    Map<String, dynamic> userWordList = await getUserWord();
    Map<String, dynamic> wordList = {};
    String comicWordPath =
        "wordlist/$title/${title}_ep${episode}_wordlist.json";
    final comicWordRef = FirebaseStorage.instance.ref().child(comicWordPath);
    String url = await comicWordRef.getDownloadURL();
    http.get(Uri.parse(url)).then((res) {
      wordList = json.decode(res.body);
    });
    return wordList;
  }
}
