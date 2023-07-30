import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nothing_gallery/classes/AlbumInfo.dart';
import 'package:nothing_gallery/classes/LifeCycleListenerState.dart';
import 'package:nothing_gallery/components/image.dart';
import 'package:nothing_gallery/constants/sharedPrefKey.dart';
import 'package:nothing_gallery/db/sharedPref.dart';
import 'package:nothing_gallery/pages/imagePage.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/util/imageFunctions.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageGridWidget extends StatefulWidget {
  final AlbumInfo album;
  late SharedPref sharedPref;

  ImageGridWidget({super.key, required this.album, required this.sharedPref});

  @override
  State createState() => _ImageGridState();
}

class _ImageGridState extends LifecycleListenerState<ImageGridWidget> {
  late AlbumInfo albumInfo;
  List<AssetEntity> loadedImages = [];
  List<Uint8List> thumbnails = [];
  int totalCount = 0;
  int currentPage = 0;
  int numCol = 4;
  int loadImageCount = 100;

  @override
  void initState() {
    super.initState();
    albumInfo = widget.album;
    totalCount = albumInfo.assetCount;
    getPreferences();

    for (int i = 0; i < 3; i++) {
      getImages();
    }
  }

  Future<void> reloadAlbum() async {
    AlbumInfo reloaded = await getAlbumInfo(albumInfo.album);
    setState(() {
      albumInfo = reloaded;
    });
  }

  void getPreferences() {
    numCol = widget.sharedPref.get(SharedPrefKeys.imageGridPageNumCol);
  }

  Future<void> getImages() async {
    currentPage += 1;
    if (albumInfo.images.length > (currentPage - 1) * loadImageCount) {
      List<AssetEntity> images = albumInfo.images.sublist(
          (currentPage - 1) * loadImageCount,
          min(currentPage * loadImageCount, albumInfo.images.length));

      setState(() {
        loadedImages = List.from(loadedImages)..addAll(images);
      });
    }
  }

  // Not used
  Future<void> getThumbnails(List<AssetEntity> images) async {
    List<Uint8List> loadedThumb = [];
    for (AssetEntity image in images) {
      Uint8List? thumbnail = await image.thumbnailDataWithSize(
          ThumbnailSize(image.orientatedWidth, image.orientatedHeight));

      if (thumbnail == null) {
        loadedThumb.add(Uint8List(0));
      } else {
        loadedThumb.add(thumbnail);
      }
    }
    setState(() {
      thumbnails = List.from(thumbnails)..addAll(loadedThumb);
    });
  }

  void _openImage(AssetEntity image, int index) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePageWidget(
            images: loadedImages,
            imageTotal: totalCount,
            index: index,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            body: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scroll) {
                  // 현재 스크롤 위치 - scroll.metrics.pixels
                  // 스크롤 끝 위치 scroll.metrics.maxScrollExtent
                  final scrollPixels =
                      scroll.metrics.pixels / scroll.metrics.maxScrollExtent;

                  if (scrollPixels > 0.6) getImages();
                  return false;
                },
                child: SafeArea(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            albumInfo.album.name.toUpperCase(),
                            style: pageTitleTextStyle(),
                          )),

                      // Images Grid
                      Expanded(
                          child: CustomScrollView(
                        primary: false,
                        slivers: <Widget>[
                          SliverPadding(
                            padding: const EdgeInsets.all(12),
                            sliver: SliverGrid.count(
                                crossAxisSpacing: 3,
                                mainAxisSpacing: 3,
                                crossAxisCount: numCol,
                                childAspectRatio: 1,
                                children: loadedImages
                                    .asMap()
                                    .entries
                                    .map((entry) => imageWidget(
                                          () => {
                                            _openImage(entry.value, entry.key)
                                          },
                                          entry.value,
                                        ))
                                    .toList()),
                          ),
                        ],
                      ))
                    ])))));
  }

  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
  }

  @override
  void onResumed() {
    reloadAlbum();
  }
}
