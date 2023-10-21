import 'package:flutter/material.dart';
import 'package:nothing_gallery/model/model.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:nothing_gallery/pages/pages.dart';
import 'package:provider/provider.dart';

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

Future<void> openImageSelection(
    BuildContext context, AlbumInfo albumInfo) async {
  await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageGridWidget(
          album: albumInfo,
          selectImage: true,
        ),
      )).then((value) {
    if (value != null) {
      Provider.of<AlbumInfoList>(context, listen: false)
          .changeAlbumThumbnail(albumInfo, value);
      Provider.of<AppStatus>(context, listen: false)
          .setCustomThumbnail(albumInfo.pathEntity.id, value);
    }
  });
}

Future<void> openAlbum(BuildContext context, AlbumInfo albumInfo) async {
  await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageGridWidget(
          album: albumInfo,
          selectImage: false,
        ),
      ));
}

Future<void> openSortingPage(BuildContext context) async {
  await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomSortPage(),
      ));
}

Future<void> openVideoPage(BuildContext context) async {
  await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VideosPage(),
      ));
}

Future<void> openFavoritePage(BuildContext context) async {
  await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavoritePage(),
      ));
}
