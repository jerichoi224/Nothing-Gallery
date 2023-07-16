import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:local_hero/local_hero.dart';
import 'package:nothing_gallery/components/image.dart';
import 'package:nothing_gallery/constants/sharedPrefKey.dart';
import 'package:nothing_gallery/db/sharedPref.dart';
import 'package:nothing_gallery/pages/imagePage.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/util/imageLoader.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageGridWidget extends StatefulWidget {
  final AssetPathEntity albumPath;
  late SharedPref sharedPref;

  ImageGridWidget(
      {super.key, required this.albumPath, required this.sharedPref});

  @override
  State createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGridWidget> {
  // Map<AssetEntity, Uint8List> images = {};
  List<AssetEntity> loadedImages = [];
  List<Uint8List> thumbnails = [];
  bool scale_modified = false;
  int totalCount = 0;
  int currentPage = 0;
  int numCol = 4;

  @override
  void initState() {
    super.initState();
    getPreferences();
    for (int i = 0; i < 3; i++) {
      getImages();
    }
  }

  void getPreferences() {
    dynamic prefCol = widget.sharedPref.get(SharedPrefKeys.imageGridPageNumCol);
    if (prefCol != null) numCol = prefCol;
  }

  Future<void> getImages() async {
    totalCount = await widget.albumPath.assetCountAsync;
    List<AssetEntity> images =
        await loadImages(widget.albumPath, currentPage++, size: 80);
    setState(() {
      loadedImages = List.from(loadedImages)..addAll(images);
    });
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
    Uint8List thumbnail = Uint8List(0);
    if (thumbnails.length > index) thumbnail = thumbnails[index];

    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePageWidget(
            images: loadedImages,
            imageTotal: totalCount,
            thumbnail: thumbnail,
            index: index,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
          setState(() {
            double _scale =
                (scaleDetails.horizontalScale + scaleDetails.verticalScale) / 2;
            if (!scale_modified) {
              if (_scale < 0.6 && numCol < 8) {
                numCol += 1;
                scale_modified = true;
                widget.sharedPref
                    .set(SharedPrefKeys.imageGridPageNumCol, numCol);
              } else if (_scale > 2 && numCol > 2) {
                numCol -= 1;
                scale_modified = true;
                widget.sharedPref
                    .set(SharedPrefKeys.imageGridPageNumCol, numCol);
              }
            }
          });
        },
        onScaleEnd: (details) {
          scale_modified = false;
        },
        behavior: HitTestBehavior.deferToChild,
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
                            widget.albumPath.name.toUpperCase(),
                            style: pageTitleTextStyle(),
                          )),

                      // Images Grid
                      Expanded(
                          child: CustomScrollView(
                        primary: false,
                        slivers: <Widget>[
                          LocalHeroScope(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: SliverPadding(
                              padding: const EdgeInsets.all(12),
                              sliver: SliverGrid.count(
                                  crossAxisSpacing: 3,
                                  mainAxisSpacing: 3,
                                  crossAxisCount: numCol,
                                  childAspectRatio: 1,
                                  children: loadedImages
                                      .asMap()
                                      .entries
                                      .map((entry) => LocalHero(
                                          tag: entry.value.id,
                                          child: imageWidget(
                                            () => {
                                              _openImage(entry.value, entry.key)
                                            },
                                            entry.value,
                                          )))
                                      .toList()),
                            ),
                          )
                        ],
                      ))
                    ])))));
  }
}
