import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nothing_gallery/classes/album_info.dart';
import 'package:nothing_gallery/components/album.dart';
import 'package:nothing_gallery/style.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumsWidget extends StatefulWidget {
  AlbumsWidget({Key? key}) : super(key: key);

  @override
  State createState() => _AlbumsState();
}

class _AlbumsState extends State<AlbumsWidget> {
  Map<AssetPathEntity, AlbumInfo> albums = {};

  @override
  void initState() {
    super.initState();
    getAlbums();
  }

  Future<void> getAlbums() async {
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList();
    paths.removeWhere((element) => element.id == 'isAll'); // remove recent
    for (AssetPathEntity path in paths) {
      int begin = 0;
      List<AssetEntity> thumbnailList =
          await path.getAssetListRange(start: begin, end: begin + 5);
      if (thumbnailList.isEmpty) continue;

      for (AssetEntity img in thumbnailList) {
        Uint8List? thumbnailData = await img.thumbnailDataWithSize(
          const ThumbnailSize.square(256),
        );

        if (thumbnailData != null) {
          AlbumInfo info = AlbumInfo(path.id, thumbnailData);
          albums[path] = info;
          break;
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            body: Column(children: [
          SizedBox(
            height: MediaQuery.of(context).viewPadding.top,
          ),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                  child: Text(
                'ALBUMS',
                style: pageTitleTextStyle(),
              ))),

          // Album Grid
          Expanded(
              child: CustomScrollView(
            primary: false,
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.all(25),
                sliver: SliverGrid.count(
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    children: albums.entries
                        .map((entry) => albumWidget(() => {}, entry.key.name,
                            entry.value.thumbnailImage))
                        .toList()),
              ),
            ],
          ))
        ])));
  }
}
