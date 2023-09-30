import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/classes/classes.dart';
import 'package:nothing_gallery/components/components.dart';
import 'package:nothing_gallery/model/model.dart';

@immutable
class AlbumsWidget extends StatefulWidget {
  const AlbumsWidget({super.key});

  @override
  State createState() => _AlbumsState();
}

class _AlbumsState extends LifecycleListenerState<AlbumsWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(body: SafeArea(child:
            Consumer<AlbumInfoList>(builder: (context, albumInfoList, child) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(30, 20, 10, 0),
                    child: Row(
                      children: [
                        Text(
                          'ALBUMS',
                          style: mainTextStyle(TextStyleType.pageTitle),
                        ),
                        const Spacer(),
                        IconButton(
                            onPressed: () {
                              albumInfoList.refreshAlbums();
                            },
                            icon: const Icon(Icons.refresh)),
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
                      padding: const EdgeInsets.all(20),
                      sliver: SliverGrid.count(
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          children: albumInfoList.albums
                              .map((albumeInfo) =>
                                  AlbumWidget(albumInfo: albumeInfo))
                              .toList()),
                    ),
                  ],
                ))
              ]);
        }))));
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
  void onResumed() {}

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
