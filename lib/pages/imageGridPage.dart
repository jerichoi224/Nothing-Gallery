import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nothing_gallery/components/image.dart';
import 'package:nothing_gallery/pages/imagePage.dart';
import 'package:nothing_gallery/style.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageGridWidget extends StatefulWidget {
  final AssetPathEntity albumPath;

  const ImageGridWidget({super.key, required this.albumPath});

  @override
  State createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGridWidget> {
  Map<AssetEntity, Uint8List> images = {};

  @override
  void initState() {
    super.initState();
    getImages();
  }

  Future<void> getImages() async {
    List<AssetEntity> entities =
        await widget.albumPath.getAssetListRange(start: 0, end: 80);
    for (AssetEntity entity in entities) {
      Uint8List? thumbnailData = await entity.thumbnailDataWithSize(
        const ThumbnailSize.square(256),
      );
      if (thumbnailData != null) {
        images[entity] = thumbnailData;
      }
    }
    setState(() {});
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
            body:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: MediaQuery.of(context).viewPadding.top,
          ),
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
                    children: images.entries
                        .map((entry) => imageWidget(
                            () => {_openImage(entry.key)}, entry.value))
                        .toList()),
              ),
            ],
          ))
        ])));
  }
}
