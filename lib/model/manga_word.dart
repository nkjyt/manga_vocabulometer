import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'manga_word.freezed.dart';

@freezed
class MangaWord with _$MangaWord {
  const MangaWord._();
  const factory MangaWord({
      String? word,
      String? title,
  }) = _MangaWord;

}
