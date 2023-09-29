import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nothing_gallery/classes/AlbumInfo.dart';
import 'package:nothing_gallery/classes/Event.dart';
import 'package:nothing_gallery/classes/LifeCycleListenerState.dart';
import 'package:nothing_gallery/components/album.dart';
import 'package:nothing_gallery/constants/event_type.dart';
import 'package:nothing_gallery/main.dart';
import 'package:nothing_gallery/style.dart';
import 'package:nothing_gallery/util/loader_functions.dart';

@immutable
class AlbumsWidget extends StatefulWidget {
  final List<AlbumInfo> albums;

  const AlbumsWidget({super.key, required this.albums});

  @override
  State createState() => _AlbumsState();
}

class _AlbumsState extends LifecycleListenerState<AlbumsWidget> {
  List<AlbumInfo> albums = [];
  StreamSubscription? eventSubscription;

  @override
  void initState() {
    super.initState();
    // only time reading widget.album
    albums = widget.albums;

    eventSubscription =
        eventController.stream.asBroadcastStream().listen((event) {
      if (event.runtimeType == Event) {
        if (event.eventType == EventType.albumEmpty) {
          if (event.details != null && event.details.runtimeType == String) {
            albums.removeWhere(
                (albumInfo) => albumInfo.album.id == event.details);
          }
        } else {}
      }
    });
  }

  Future<void> reloadAlbums() async {
    List<AlbumInfo> reloadedAlbums = await getInitialAlbums();
    setState(() {
      albums = reloadedAlbums;
    });
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
                        style: mainTextStyle(TextStyleType.pageTitle),
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
                            .map((albumeInfo) =>
                                AlbumWidget(albumInfo: albumeInfo))
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

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
