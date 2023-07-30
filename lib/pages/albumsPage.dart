import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nothing_gallery/classes/AlbumInfo.dart';
import 'package:nothing_gallery/classes/LifeCycleListenerState.dart';
import 'package:nothing_gallery/components/album.dart';
import 'package:nothing_gallery/db/sharedPref.dart';
import 'package:nothing_gallery/pages/imageGridPage.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/util/imageFunctions.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumsWidget extends StatefulWidget {
  late SharedPref sharedPref;
  late List<AlbumInfo> albums;

  AlbumsWidget({super.key, required this.sharedPref, required this.albums});

  @override
  State createState() => _AlbumsState();
}

class _AlbumsState extends LifecycleListenerState<AlbumsWidget> {
  List<AlbumInfo> albums = [];

  @override
  void initState() {
    super.initState();
    albums = widget.albums;
  }

  Future<void> reloadAlbums() async {
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList();
    paths.removeWhere((element) => element.id == 'isAll'); // remove recent

    List<AlbumInfo> reloaded = [];
    for (AssetPathEntity path in paths) {
      reloaded.add(await getAlbumInfo(path));
    }

    setState(() {
      albums = reloaded;
      widget.albums = reloaded;
    });
  }

  void _openAlbum(AlbumInfo album) async {
    bool needReload = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageGridWidget(
            album: album,
            sharedPref: widget.sharedPref,
          ),
        ));

    if (needReload) {
      reloadAlbums();
    }
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
                  child: Row(
                    children: [
                      Text(
                        'ALBUMS',
                        style: pageTitleTextStyle(),
                      ),
                      const Spacer(),
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.search))
                    ],
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
                            .map((entry) =>
                                albumWidget(() => {_openAlbum(entry)}, entry))
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
    reloadAlbums();
  }
}
