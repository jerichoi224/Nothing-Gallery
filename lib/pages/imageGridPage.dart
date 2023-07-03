import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nothing_gallery/components/image.dart';
import 'package:nothing_gallery/pages/imagePage.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/util/imageLoader.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageGridWidget extends StatefulWidget {
  final AssetPathEntity albumPath;

  const ImageGridWidget({super.key, required this.albumPath});

  @override
  State createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGridWidget> {
  // Map<AssetEntity, Uint8List> images = {};
  List<AssetEntity> loadedImages = [];
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    getImages();
  }

  Future<void> getImages() async {
    List<AssetEntity> images = await loadImages(widget.albumPath, currentPage++);
    setState(() {
      loadedImages = List.from(loadedImages)..addAll(images);
      print(loadedImages.length);
    });
  }

  void _openImage(AssetEntity image) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePageWidget(
            image: image,
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

                  if (scrollPixels > 0.7) getImages();
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
                          SliverPadding(
                            padding: const EdgeInsets.all(12),
                            sliver: SliverGrid.count(
                                crossAxisSpacing: 3,
                                mainAxisSpacing: 3,
                                crossAxisCount: 4,
                                childAspectRatio: 1,
                                children: loadedImages
                                    .map((entry) => imageWidget(
                                        () => {_openImage(entry)}, entry))
                                    .toList()),
                          ),
                        ],
                      ))
                    ])))));
  }
}
