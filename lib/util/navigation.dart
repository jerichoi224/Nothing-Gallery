import 'package:flutter/material.dart';
import 'package:nothing_gallery/pages/image_page.dart';
import 'package:nothing_gallery/pages/settings_page.dart';
import 'package:nothing_gallery/pages/video_player_page.dart';
import 'package:photo_manager/photo_manager.dart';

void openSettings(BuildContext context) async {
  await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(),
      ));
}

void openVideoPlayerPage(BuildContext context, AssetEntity video) async {
  await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerPageWidget(
          video: video,
        ),
      ));
}

void openImagePage(BuildContext context, int index, int imageCount,
    List<AssetEntity> images) async {
  await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePageWidget(
          images: images,
          imageTotal: imageCount,
          index: index,
        ),
      ));
}
