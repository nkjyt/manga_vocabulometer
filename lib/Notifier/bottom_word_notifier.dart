import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mangavocabulometer/manga/Manga.dart';
import 'package:mangavocabulometer/repositories/manga_word_repository.dart';

class BottomWordNotifier extends StateNotifier<Map<String, bool>> {
  BottomWordNotifier() : super({});

  MangaWordRepository _repository = MangaWordRepository();

  Future<void> fetchData(Manga manga, int selectedEpisode) async {
    Map<String, dynamic> userWordList = await _repository.getUserWord();
    Map<String, dynamic> mangaWordList = await _repository.loadWordLists(
        manga.title, selectedEpisode.toString());
        
  }
}
