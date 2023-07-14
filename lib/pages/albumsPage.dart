import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nothing_gallery/classes/AlbumInfo.dart';
import 'package:nothing_gallery/classes/LifeCycleListenerState.dart';
import 'package:nothing_gallery/components/album.dart';
import 'package:nothing_gallery/pages/imageGridPage.dart';
import 'package:nothing_gallery/style.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumsWidget extends StatefulWidget {
  AlbumsWidget({Key? key}) : super(key: key);

  @override
  State createState() => _AlbumsState();
}

class _AlbumsState extends LifecycleListenerState<AlbumsWidget> {
  List<AlbumInfo> albums = [];

  @override
  void initState() {
    super.initState();
    getAlbums();
  }

  Future<void> getAlbums() async {
    albums = [];
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList();
    paths.removeWhere((element) => element.id == 'isAll'); // remove recent
    for (AssetPathEntity path in paths) {
      List<AssetEntity> thumbnailList =
          await path.getAssetListRange(start: 0, end: 1);
      if (thumbnailList.isEmpty) continue;
      int assetCount = await path.assetCountAsync;
      AlbumInfo info = AlbumInfo(path, thumbnailList[0], assetCount);
      albums.add(info);
    }
    setState(() {});
  }

  void _openAlbum(AssetPathEntity album) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageGridWidget(
            albumPath: album,
          ),
        ));
    getAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            body: SafeArea(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 10, 20),
                  child: Text(
                    'ALBUMS',
                    style: pageTitleTextStyle(),
                  )),
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
                        children: albums
                            .map((entry) => albumWidget(
                                () => {_openAlbum(entry.album)}, entry))
                            .toList()),
                  ),
                ],
              ))
            ]))));
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
    getAlbums();
  }
}
