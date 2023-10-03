import 'package:flutter/material.dart';
import 'package:nothing_gallery/util/util.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

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

class _AlbumsState extends LifecycleListenerState<AlbumsWidget>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(body: SafeArea(child:
            Consumer<AlbumInfoList>(builder: (context, albumInfoList, child) {
          print(albumInfoList.albums.length);
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Text(
                          'ALBUMS',
                          style: mainTextStyle(TextStyleType.pageTitle),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            albumInfoList.refreshAlbums();
                            _controller.forward().then((value) {
                              _controller.reset();
                            });
                          },
                          child: RotationTransition(
                            turns: Tween(begin: 0.0, end: 1.0)
                                .animate(_controller),
                            child: const Icon(Icons.refresh_rounded),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
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
                        padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                        sliver: SliverGrid.count(
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            children: [
                              WideIconButton(
                                  text: "FAVORITE",
                                  iconData: Icons.favorite_border_rounded,
                                  onTapHandler: () {}),
                              WideIconButton(
                                text: "VIDEOS",
                                iconData: Icons.video_library_rounded,
                                onTapHandler: () {
                                  openVideoPage(context);
                                },
                              )
                            ])),
                    SliverPadding(
                        padding: const EdgeInsets.all(10),
                        sliver: SliverGrid.count(
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            children: albumInfoList.albums
                                .map((albumeInfo) =>
                                    AlbumWidget(albumInfo: albumeInfo))
                                .toList())),
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
  void onResumed() {
    Provider.of<AlbumInfoList>(context, listen: false).refreshAlbums();
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
