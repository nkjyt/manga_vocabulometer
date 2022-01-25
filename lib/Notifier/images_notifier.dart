import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mangavocabulometer/repositories/image_repository.dart';
import 'package:mangavocabulometer/manga/Manga.dart';

final imagesNotifierProvider =
    StateNotifierProvider<ImagesNotifier, List<CachedNetworkImageProvider>>(
        (ref) => ImagesNotifier());

final jpnImagesNotifierProvider =
    StateNotifierProvider<JpnImagesNotifier, List<CachedNetworkImageProvider>>(
        (ref) => JpnImagesNotifier());

//Notifier of English images
class ImagesNotifier extends StateNotifier<List<CachedNetworkImageProvider>> {
  ImagesNotifier() : super([]);

  ImageRepository _repository = ImageRepository();

  Future<void> fetchData(
      BuildContext context, Manga manga, int selectedEpisode) async {
    print("hogehoge");
    List<String> urls = await _repository.getImagesENG(manga, selectedEpisode);
    List<CachedNetworkImageProvider> images = [];
    var configuration = createLocalImageConfiguration(context);
    urls.forEach((value) {
      images.add(new CachedNetworkImageProvider(value)..resolve(configuration));
    });
    state = images;
  }
}

class JpnImagesNotifier
    extends StateNotifier<List<CachedNetworkImageProvider>> {
  JpnImagesNotifier() : super([]);

  ImageRepository _repository = ImageRepository();

  Future<void> fetchData(
      BuildContext context, Manga manga, int selectedEpisode) async {
    List<String> urls = await _repository.getImagesJPN(manga, selectedEpisode);
    List<CachedNetworkImageProvider> images = [];
    var configuration = createLocalImageConfiguration(context);
    urls.forEach((value) {
      images.add(new CachedNetworkImageProvider(value)..resolve(configuration));
    });
    state = images;
  }
}
