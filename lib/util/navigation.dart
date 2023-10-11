import 'package:flutter/material.dart';
import 'package:nothing_gallery/model/model.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:nothing_gallery/pages/pages.dart';

void openSettings(BuildContext context) async {
  await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ));
}

Future<void> openVideoPlayerPage(
    BuildContext context, AssetEntity video) async {
  await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerPageWidget(
          video: video,
        ),
      ));
}

Future<void> openImagePage(
    BuildContext context, int index, int imageCount, List<AssetEntity> images,
    {bool favoritesPage = false}) async {
  await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePageWidget(
            images: images,
            imageTotal: imageCount,
            index: index,
            favoritesPage: favoritesPage),
      ));
}

void openAlbum(BuildContext context, AlbumInfo albumInfo) async {
  await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageGridWidget(
          album: albumInfo,
        ),
      ));
}

void openVideoPage(BuildContext context) async {
  await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VideosPage(),
      ));
}

void openFavoritePage(BuildContext context) async {
  await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavoritePage(),
      ));
}
