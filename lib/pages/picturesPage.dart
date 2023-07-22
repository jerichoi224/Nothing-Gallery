import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nothing_gallery/components/image.dart';
import 'package:nothing_gallery/pages/imagePage.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/util/imageLoader.dart';
import 'package:photo_manager/photo_manager.dart';

class PicturesWidget extends StatefulWidget {
  PicturesWidget({Key? key}) : super(key: key);

  @override
  State createState() => _PicturesState();
}

class _PicturesState extends State<PicturesWidget> {
  late AssetPathEntity recent;
  List<AssetEntity> loadedImages = [];
  List<Widget> chunksByDate = [];
  int totalCount = 0;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    getRecent();
  }

  Future<void> getRecent() async {
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList();
    setState(() {
      recent =
          paths.firstWhere((element) => element.id == 'isAll'); // remove recent
      getImages();
    });
  }

  Future<void> getImages() async {
    totalCount = await recent.assetCountAsync;
    List<AssetEntity> images =
        await loadImages(recent, currentPage++, size: 100);
    setState(() {
      loadedImages = images;
      //List.from(loadedImages)..addAll(images);
    });
  }

  void _openImage(AssetEntity image, int index) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePageWidget(
            images: loadedImages,
            imageTotal: totalCount,
            thumbnail: Uint8List(0),
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
                          padding: const EdgeInsets.fromLTRB(30, 20, 10, 20),
                          child: Text(
                            'PICTURES',
                            style: pageTitleTextStyle(),
                          )),
                      // Images Grid
                      Expanded(
                          child: Column(
                        children: chunksByDate,
                      )),
                    ])))));
  }
}
